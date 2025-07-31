using Azure;
using Azure.Data.Tables;
using System.Text.Json.Serialization;

namespace ExamPlatform.Functions.Models
{
    public class QuestionEntity : ITableEntity
    {
        public string PartitionKey { get; set; } = string.Empty; // ExamType (e.g., "AZ-104")
        public string RowKey { get; set; } = string.Empty; // QuestionId (e.g., "az104-001")
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }

        public string Id { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Difficulty { get; set; } = string.Empty;
        public string Question { get; set; } = string.Empty;
        public string OptionsJson { get; set; } = string.Empty; // JSON array of options
        public int CorrectAnswer { get; set; }
        public string Explanation { get; set; } = string.Empty;
    }

    public class QuestionDto
    {
        public string Id { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Difficulty { get; set; } = string.Empty;
        public string Question { get; set; } = string.Empty;
        public List<string> Options { get; set; } = new();
        public int CorrectAnswer { get; set; }
        public string Explanation { get; set; } = string.Empty;
    }

    public class ExamSessionEntity : ITableEntity
    {
        public string PartitionKey { get; set; } = string.Empty; // UserId
        public string RowKey { get; set; } = string.Empty; // SessionId
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }

        public string SessionId { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public string QuestionsJson { get; set; } = string.Empty; // JSON array of question IDs
        public string AnswersJson { get; set; } = string.Empty; // JSON array of user answers
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int Score { get; set; }
        public bool IsCompleted { get; set; }
    }

    public class ExamSessionDto
    {
        public string SessionId { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public List<string> Questions { get; set; } = new();
        public List<int> Answers { get; set; } = new();
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int Score { get; set; }
        public bool IsCompleted { get; set; }
    }
}
