using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace ExamPlatform.Functions.Functions
{
    public class HealthFunctions
    {
        private readonly ILogger _logger;

        public HealthFunctions(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<HealthFunctions>();
        }

        [Function("Health")]
        public HttpResponseData Health(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] HttpRequestData req)
        {
            _logger.LogInformation("Health check requested");

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");
            
            var healthStatus = new { 
                status = "healthy", 
                timestamp = DateTime.UtcNow,
                version = "1.0.0",
                service = "Azure Practice Exam Platform API"
            };
            
            response.WriteString(System.Text.Json.JsonSerializer.Serialize(healthStatus));
            return response;
        }
    }
}
