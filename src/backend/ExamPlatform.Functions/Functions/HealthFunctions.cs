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

        [Function("HealthCheck")]
        public async Task<HttpResponseData> HealthCheck(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "health")] HttpRequestData req)
        {
            _logger.LogInformation("Health check requested");

            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { 
                status = "healthy", 
                timestamp = DateTime.UtcNow,
                message = "Azure Function App is running"
            });
            
            return response;
        }

        [Function("Ping")]
        public async Task<HttpResponseData> Ping(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "ping")] HttpRequestData req)
        {
            _logger.LogInformation("Ping requested");

            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteStringAsync("pong");
            
            return response;
        }
    }
}
