// API service for Azure Practice Exam Platform
const API_BASE = 'https://azpracticeexam-dev-functions.azurewebsites.net/api';

export interface Question {
  id: string;
  examType: string;
  category: string;
  difficulty: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation: string;
}

export interface ExamSession {
  sessionId: string;
  userId: string;
  examType: string;
  questions: string[];
  startTime: string;
  isCompleted: boolean;
}

export interface ExamResult {
  sessionId: string;
  score: number;
  correctAnswers: number;
  totalQuestions: number;
  completionTime: string;
}

// Health check
export const checkHealth = async (): Promise<any> => {
  const response = await fetch(`${API_BASE}/health`);
  if (!response.ok) {
    throw new Error('Health check failed');
  }
  return response.json();
};

// Get all questions for an exam type
export const getQuestions = async (examType: string): Promise<Question[]> => {
  const response = await fetch(`${API_BASE}/questions/${examType}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch questions: ${response.statusText}`);
  }
  return response.json();
};

// Get random questions for an exam
export const getRandomQuestions = async (examType: string, count: number): Promise<Question[]> => {
  const response = await fetch(`${API_BASE}/questions/${examType}/random/${count}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch random questions: ${response.statusText}`);
  }
  return response.json();
};

// Start an exam session
export const startExamSession = async (examType: string, userId?: string, questionCount?: number): Promise<ExamSession> => {
  const response = await fetch(`${API_BASE}/exam/start`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      examType,
      userId: userId || 'anonymous',
      questionCount: questionCount || 20
    }),
  });
  
  if (!response.ok) {
    throw new Error(`Failed to start exam session: ${response.statusText}`);
  }
  return response.json();
};

// Submit an answer
export const submitAnswer = async (
  sessionId: string, 
  questionIndex: number, 
  selectedAnswer: number, 
  userId?: string
): Promise<void> => {
  const response = await fetch(`${API_BASE}/exam/answer`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      sessionId,
      userId: userId || 'anonymous',
      questionIndex,
      selectedAnswer
    }),
  });
  
  if (!response.ok) {
    throw new Error(`Failed to submit answer: ${response.statusText}`);
  }
};

// Complete exam and get results
export const completeExam = async (sessionId: string, userId?: string): Promise<ExamResult> => {
  const response = await fetch(`${API_BASE}/exam/complete`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      sessionId,
      userId: userId || 'anonymous'
    }),
  });
  
  if (!response.ok) {
    throw new Error(`Failed to complete exam: ${response.statusText}`);
  }
  return response.json();
};

// Add a new question (admin function)
export const addQuestion = async (question: Omit<Question, 'id'>): Promise<Question> => {
  const response = await fetch(`${API_BASE}/questions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(question),
  });
  
  if (!response.ok) {
    throw new Error(`Failed to add question: ${response.statusText}`);
  }
  return response.json();
};
