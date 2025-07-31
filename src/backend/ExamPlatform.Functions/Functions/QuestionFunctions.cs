using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure.Data.Tables;
using ExamPlatform.Functions.Models;
using System.Net;
using System.Text.Json;

namespace ExamPlatform.Functions.Functions
{
    public class QuestionFunctions
    {
        private readonly ILogger _logger;
        private readonly TableServiceClient _tableServiceClient;

        public QuestionFunctions(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<QuestionFunctions>();
            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            _tableServiceClient = new TableServiceClient(connectionString);
        }

        [Function("GetQuestions")]
        public async Task<HttpResponseData> GetQuestions(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "questions/{examType}")] HttpRequestData req,
            string examType)
        {
            _logger.LogInformation($"Getting questions for exam type: {examType}");

            try
            {
                var tableClient = _tableServiceClient.GetTableClient("Questions");
                await tableClient.CreateIfNotExistsAsync();

                var questions = new List<QuestionDto>();
                
                await foreach (var entity in tableClient.QueryAsync<QuestionEntity>(q => q.PartitionKey == examType.ToUpper()))
                {
                    var questionDto = new QuestionDto
                    {
                        Id = entity.Id,
                        ExamType = entity.ExamType,
                        Category = entity.Category,
                        Difficulty = entity.Difficulty,
                        Question = entity.Question,
                        Options = JsonSerializer.Deserialize<List<string>>(entity.OptionsJson) ?? new List<string>(),
                        CorrectAnswer = entity.CorrectAnswer,
                        Explanation = entity.Explanation
                    };
                    questions.Add(questionDto);
                }

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(questions);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting questions");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error retrieving questions");
                return response;
            }
        }

        [Function("GetRandomQuestions")]
        public async Task<HttpResponseData> GetRandomQuestions(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "questions/{examType}/random/{count:int}")] HttpRequestData req,
            string examType,
            int count)
        {
            _logger.LogInformation($"Getting {count} random questions for exam type: {examType}");

            try
            {
                var tableClient = _tableServiceClient.GetTableClient("Questions");
                await tableClient.CreateIfNotExistsAsync();

                var allQuestions = new List<QuestionDto>();
                
                await foreach (var entity in tableClient.QueryAsync<QuestionEntity>(q => q.PartitionKey == examType.ToUpper()))
                {
                    var questionDto = new QuestionDto
                    {
                        Id = entity.Id,
                        ExamType = entity.ExamType,
                        Category = entity.Category,
                        Difficulty = entity.Difficulty,
                        Question = entity.Question,
                        Options = JsonSerializer.Deserialize<List<string>>(entity.OptionsJson) ?? new List<string>(),
                        CorrectAnswer = entity.CorrectAnswer,
                        Explanation = entity.Explanation
                    };
                    allQuestions.Add(questionDto);
                }

                // Get random subset
                var random = new Random();
                var randomQuestions = allQuestions.OrderBy(x => random.Next()).Take(count).ToList();

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(randomQuestions);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting random questions");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error retrieving questions");
                return response;
            }
        }

        [Function("AddQuestion")]
        public async Task<HttpResponseData> AddQuestion(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "questions")] HttpRequestData req)
        {
            _logger.LogInformation("Adding new question");

            try
            {
                var body = await req.ReadAsStringAsync();
                var questionDto = JsonSerializer.Deserialize<QuestionDto>(body ?? "");
                
                if (questionDto == null)
                {
                    var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                    await badResponse.WriteStringAsync("Invalid question data");
                    return badResponse;
                }

                var tableClient = _tableServiceClient.GetTableClient("Questions");
                await tableClient.CreateIfNotExistsAsync();

                var entity = new QuestionEntity
                {
                    PartitionKey = questionDto.ExamType.ToUpper(),
                    RowKey = questionDto.Id,
                    Id = questionDto.Id,
                    ExamType = questionDto.ExamType,
                    Category = questionDto.Category,
                    Difficulty = questionDto.Difficulty,
                    Question = questionDto.Question,
                    OptionsJson = JsonSerializer.Serialize(questionDto.Options),
                    CorrectAnswer = questionDto.CorrectAnswer,
                    Explanation = questionDto.Explanation
                };

                await tableClient.AddEntityAsync(entity);

                var response = req.CreateResponse(HttpStatusCode.Created);
                await response.WriteAsJsonAsync(questionDto);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding question");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync("Error adding question");
                return response;
            }
        }
    }
}
