using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure.Data.Tables;
using ExamPlatform.Functions.Models;
using System.Net;
using System.Text.Json;

namespace ExamPlatform.Functions.Functions
{
    public class ExamSessionFunctions
    {
        private readonly ILogger _logger;
        private readonly TableServiceClient _tableServiceClient;

        public ExamSessionFunctions(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ExamSessionFunctions>();
            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            _tableServiceClient = new TableServiceClient(connectionString);
        }

        [Function("StartExamSession")]
        public async Task<HttpResponseData> StartExamSession(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "exam/start")] HttpRequestData req)
        {
            _logger.LogInformation("Starting new exam session");

            try
            {
                var body = await req.ReadAsStringAsync();
                var request = JsonSerializer.Deserialize<StartExamRequest>(body ?? "");
                
                if (request == null || string.IsNullOrEmpty(request.ExamType))
                {
                    var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badResponse.WriteStringAsync("Invalid request data");
                    return badResponse;
                }

                var sessionId = Guid.NewGuid().ToString();
                var userId = request.UserId ?? "anonymous";

                // Get questions for the exam
                var questionsTableClient = _tableServiceClient.GetTableClient("Questions");
                var questions = new List<string>();
                
                await foreach (var entity in questionsTableClient.QueryAsync<QuestionEntity>(
                    q => q.PartitionKey == request.ExamType.ToUpper()))
                {
                    questions.Add(entity.Id);
                }

                // Randomize and limit questions
                var random = new Random();
                var selectedQuestions = questions.OrderBy(x => random.Next())
                    .Take(request.QuestionCount ?? 20)
                    .ToList();

                // Create exam session
                var sessionsTableClient = _tableServiceClient.GetTableClient("ExamSessions");
                await sessionsTableClient.CreateIfNotExistsAsync();

                var sessionEntity = new ExamSessionEntity
                {
                    PartitionKey = userId,
                    RowKey = sessionId,
                    SessionId = sessionId,
                    UserId = userId,
                    ExamType = request.ExamType,
                    QuestionsJson = JsonSerializer.Serialize(selectedQuestions),
                    AnswersJson = JsonSerializer.Serialize(new int[selectedQuestions.Count]),
                    StartTime = DateTime.UtcNow,
                    IsCompleted = false,
                    Score = 0
                };

                await sessionsTableClient.AddEntityAsync(sessionEntity);

                var sessionDto = new ExamSessionDto
                {
                    SessionId = sessionId,
                    UserId = userId,
                    ExamType = request.ExamType,
                    Questions = selectedQuestions,
                    StartTime = sessionEntity.StartTime,
                    IsCompleted = false
                };

                var response = req.CreateResponse(HttpStatusCode.Created);
                await response.WriteAsJsonAsync(sessionDto);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error starting exam session");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error starting exam session");
                return response;
            }
        }

        [Function("SubmitAnswer")]
        public async Task<HttpResponseData> SubmitAnswer(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "exam/answer")] HttpRequestData req)
        {
            _logger.LogInformation("Submitting answer");

            try
            {
                var body = await req.ReadAsStringAsync();
                var request = JsonSerializer.Deserialize<SubmitAnswerRequest>(body ?? "");
                
                if (request == null)
                {
                    var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badResponse.WriteStringAsync("Invalid request data");
                    return badResponse;
                }

                var sessionsTableClient = _tableServiceClient.GetTableClient("ExamSessions");
                var sessionEntity = await sessionsTableClient.GetEntityAsync<ExamSessionEntity>(
                    request.UserId ?? "anonymous", request.SessionId);

                if (sessionEntity == null)
                {
                    var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                    await notFoundResponse.WriteStringAsync("Session not found");
                    return notFoundResponse;
                }

                // Update answers
                var answers = JsonSerializer.Deserialize<int[]>(sessionEntity.Value.AnswersJson) ?? new int[0];
                if (request.QuestionIndex >= 0 && request.QuestionIndex < answers.Length)
                {
                    answers[request.QuestionIndex] = request.SelectedAnswer;
                    sessionEntity.Value.AnswersJson = JsonSerializer.Serialize(answers);
                    
                    await sessionsTableClient.UpdateEntityAsync(sessionEntity.Value, sessionEntity.Value.ETag);
                }

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteStringAsync("Answer submitted successfully");
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error submitting answer");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error submitting answer");
                return response;
            }
        }

        [Function("CompleteExam")]
        public async Task<HttpResponseData> CompleteExam(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "exam/complete")] HttpRequestData req)
        {
            _logger.LogInformation("Completing exam");

            try
            {
                var body = await req.ReadAsStringAsync();
                var request = JsonSerializer.Deserialize<CompleteExamRequest>(body ?? "");
                
                if (request == null)
                {
                    var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badResponse.WriteStringAsync("Invalid request data");
                    return badResponse;
                }

                var sessionsTableClient = _tableServiceClient.GetTableClient("ExamSessions");
                var sessionEntity = await sessionsTableClient.GetEntityAsync<ExamSessionEntity>(
                    request.UserId ?? "anonymous", request.SessionId);

                // Calculate score
                var questions = JsonSerializer.Deserialize<string[]>(sessionEntity.Value.QuestionsJson) ?? new string[0];
                var answers = JsonSerializer.Deserialize<int[]>(sessionEntity.Value.AnswersJson) ?? new int[0];
                
                var questionsTableClient = _tableServiceClient.GetTableClient("Questions");
                int correctAnswers = 0;

                for (int i = 0; i < questions.Length && i < answers.Length; i++)
                {
                    var questionEntity = await questionsTableClient.GetEntityAsync<QuestionEntity>(
                        sessionEntity.Value.ExamType.ToUpper(), questions[i]);
                    
                    if (questionEntity.Value.CorrectAnswer == answers[i])
                    {
                        correctAnswers++;
                    }
                }

                var score = (int)Math.Round((double)correctAnswers / questions.Length * 100);

                // Update session
                sessionEntity.Value.EndTime = DateTime.UtcNow;
                sessionEntity.Value.Score = score;
                sessionEntity.Value.IsCompleted = true;

                await sessionsTableClient.UpdateEntityAsync(sessionEntity.Value, sessionEntity.Value.ETag);

                var result = new ExamResultDto
                {
                    SessionId = request.SessionId,
                    Score = score,
                    CorrectAnswers = correctAnswers,
                    TotalQuestions = questions.Length,
                    CompletionTime = sessionEntity.Value.EndTime.Value
                };

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(result);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error completing exam");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error completing exam");
                return response;
            }
        }
    }

    public class StartExamRequest
    {
        public string ExamType { get; set; } = string.Empty;
        public string? UserId { get; set; }
        public int? QuestionCount { get; set; }
    }

    public class SubmitAnswerRequest
    {
        public string SessionId { get; set; } = string.Empty;
        public string? UserId { get; set; }
        public int QuestionIndex { get; set; }
        public int SelectedAnswer { get; set; }
    }

    public class CompleteExamRequest
    {
        public string SessionId { get; set; } = string.Empty;
        public string? UserId { get; set; }
    }

    public class ExamResultDto
    {
        public string SessionId { get; set; } = string.Empty;
        public int Score { get; set; }
        public int CorrectAnswers { get; set; }
        public int TotalQuestions { get; set; }
        public DateTime CompletionTime { get; set; }
    }
}
