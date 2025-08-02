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

        public QuestionFunctions(ILoggerFactory loggerFactory, TableServiceClient tableServiceClient)
        {
            _logger = loggerFactory.CreateLogger<QuestionFunctions>();
            _tableServiceClient = tableServiceClient;
        }

        [Function("GetQuestions")]
        public async Task<HttpResponseData> GetQuestions(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "questions/{examType}")] HttpRequestData req,
            string examType)
        {
            _logger.LogInformation($"Getting questions for exam type: {examType}");

            try
            {
                var tableClient = _tableServiceClient.GetTableClient("Questions");
                await tableClient.CreateIfNotExistsAsync();

                var questions = new List<QuestionDto>();
                
                await foreach (var entity in tableClient.QueryAsync<TableEntity>(q => q.PartitionKey == examType.ToUpper()))
                {
                    try
                    {
                        // Handle malformed JSON gracefully
                        List<string> options = new List<string>();
                        
                        var optionsJson = entity.GetString("OptionsJson") ?? "";
                        if (!string.IsNullOrEmpty(optionsJson))
                        {
                            try
                            {
                                // Try to deserialize as proper JSON first
                                options = JsonSerializer.Deserialize<List<string>>(optionsJson) ?? new List<string>();
                            }
                            catch (JsonException)
                            {
                                // If JSON is malformed (missing quotes), try to fix it
                                _logger.LogWarning($"Malformed JSON in question {entity.GetString("Id")}: {optionsJson}");
                                
                                // Try to parse malformed JSON like: [Option1,Option2,Option3]
                                var fixedJson = FixMalformedJson(optionsJson);
                                _logger.LogInformation($"Attempting to fix JSON for {entity.GetString("Id")}: {fixedJson}");
                                
                                try
                                {
                                    options = JsonSerializer.Deserialize<List<string>>(fixedJson) ?? new List<string>();
                                }
                                catch
                                {
                                    // If all else fails, create default options
                                    _logger.LogError($"Could not parse options for question {entity.GetString("Id")}, using defaults");
                                    options = new List<string> { "Option A", "Option B", "Option C", "Option D" };
                                }
                            }
                        }

                        // Handle CorrectAnswer conversion (might be stored as string)
                        int correctAnswer = 0;
                        var correctAnswerValue = entity["CorrectAnswer"];
                        if (correctAnswerValue != null)
                        {
                            if (correctAnswerValue is int intValue)
                            {
                                correctAnswer = intValue;
                            }
                            else if (correctAnswerValue is string stringValue && int.TryParse(stringValue, out int parsedValue))
                            {
                                correctAnswer = parsedValue;
                            }
                            else
                            {
                                _logger.LogWarning($"Could not parse CorrectAnswer for question {entity.GetString("Id")}: {correctAnswerValue}");
                            }
                        }

                        var questionDto = new QuestionDto
                        {
                            Id = entity.GetString("Id") ?? "",
                            ExamType = entity.GetString("ExamType") ?? "",
                            Category = entity.GetString("Category") ?? "",
                            Difficulty = entity.GetString("Difficulty") ?? "",
                            Question = entity.GetString("Question") ?? "",
                            Options = options,
                            CorrectAnswer = correctAnswer,
                            Explanation = entity.GetString("Explanation") ?? ""
                        };
                        questions.Add(questionDto);
                    }
                    catch (Exception entityEx)
                    {
                        _logger.LogError(entityEx, $"Error processing question entity {entity.GetString("Id")}");
                        // Skip this question and continue with others
                        continue;
                    }
                }

                _logger.LogInformation($"Successfully processed {questions.Count} questions for {examType}");

                var response = req.CreateResponse(HttpStatusCode.OK);
                await response.WriteAsJsonAsync(questions);
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting questions");
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                await response.WriteStringAsync($"Error retrieving questions: {ex.Message}");
                return response;
            }
        }

        // Helper method to fix malformed JSON
        private string FixMalformedJson(string malformedJson)
        {
            if (string.IsNullOrEmpty(malformedJson))
                return "[]";

            try
            {
                // Handle format like: [Option1,Option2,Option3]
                if (malformedJson.StartsWith("[") && malformedJson.EndsWith("]"))
                {
                    var inner = malformedJson.Substring(1, malformedJson.Length - 2);
                    var parts = inner.Split(',');
                    var quotedParts = parts.Select(p => $"\"{p.Trim()}\"");
                    return $"[{string.Join(",", quotedParts)}]";
                }
            }
            catch
            {
                // If fixing fails, return empty array
            }

            return "[]";
        }

        [Function("GetRandomQuestions")]
        public async Task<HttpResponseData> GetRandomQuestions(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "questions/{examType}/random/{count:int}")] HttpRequestData req,
            string examType,
            int count)
        {
            _logger.LogInformation($"Getting {count} random questions for exam type: {examType}");

            try
            {
                var tableClient = _tableServiceClient.GetTableClient("Questions");
                await tableClient.CreateIfNotExistsAsync();

                var allQuestions = new List<QuestionDto>();
                
                await foreach (var entity in tableClient.QueryAsync<TableEntity>(q => q.PartitionKey == examType.ToUpper()))
                {
                    try
                    {
                        // Use the same JSON handling logic
                        List<string> options = new List<string>();
                        
                        var optionsJson = entity.GetString("OptionsJson") ?? "";
                        if (!string.IsNullOrEmpty(optionsJson))
                        {
                            try
                            {
                                options = JsonSerializer.Deserialize<List<string>>(optionsJson) ?? new List<string>();
                            }
                            catch (JsonException)
                            {
                                var fixedJson = FixMalformedJson(optionsJson);
                                try
                                {
                                    options = JsonSerializer.Deserialize<List<string>>(fixedJson) ?? new List<string>();
                                }
                                catch
                                {
                                    options = new List<string> { "Option A", "Option B", "Option C", "Option D" };
                                }
                            }
                        }

                        // Handle CorrectAnswer conversion
                        int correctAnswer = 0;
                        var correctAnswerValue = entity["CorrectAnswer"];
                        if (correctAnswerValue != null)
                        {
                            if (correctAnswerValue is int intValue)
                            {
                                correctAnswer = intValue;
                            }
                            else if (correctAnswerValue is string stringValue && int.TryParse(stringValue, out int parsedValue))
                            {
                                correctAnswer = parsedValue;
                            }
                        }

                        var questionDto = new QuestionDto
                        {
                            Id = entity.GetString("Id") ?? "",
                            ExamType = entity.GetString("ExamType") ?? "",
                            Category = entity.GetString("Category") ?? "",
                            Difficulty = entity.GetString("Difficulty") ?? "",
                            Question = entity.GetString("Question") ?? "",
                            Options = options,
                            CorrectAnswer = correctAnswer,
                            Explanation = entity.GetString("Explanation") ?? ""
                        };
                        allQuestions.Add(questionDto);
                    }
                    catch (Exception entityEx)
                    {
                        _logger.LogError(entityEx, $"Error processing question entity {entity.GetString("Id")}");
                        continue;
                    }
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
                await response.WriteStringAsync($"Error retrieving questions: {ex.Message}");
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
                await response.WriteStringAsync($"Error adding question: {ex.Message}");
                return response;
            }
        }
    }
}