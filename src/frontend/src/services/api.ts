// Enhanced API service for Azure Practice Exam Platform
// Includes retry logic, proper error handling, and configuration management

import { config, logConfiguration, validateConfiguration } from '../config/environment';
import { 
  handleApiError, 
  logError, 
  shouldRetry, 
  calculateBackoffDelay,
  ApiError
} from './errorHandler';

// Initialize configuration logging
if (config.enableDebugLogging) {
  logConfiguration();
  validateConfiguration();
}

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

/**
 * Enhanced fetch wrapper with retry logic and error handling
 */
const fetchWithRetry = async (
  url: string, 
  options: RequestInit = {}, 
  maxRetries: number = config.retryAttempts
): Promise<Response> => {
  let lastError: unknown;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), config.requestTimeout);
      
      const response = await fetch(url, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...options.headers,
        },
        signal: controller.signal,
      });
      
      clearTimeout(timeoutId);
      
      // If successful, return immediately
      if (response.ok) {
        if (config.enableDebugLogging) {
          console.log(`✅ API Success: ${url} (attempt ${attempt + 1})`);
        }
        return response;
      }
      
      // For non-2xx responses, decide whether to retry
      const error = handleApiError(response, url);
      
      if (!shouldRetry(error, attempt, maxRetries)) {
        throw error;
      }
      
      lastError = error;
      
      if (config.enableDebugLogging) {
        console.warn(`⚠️ API Error: ${url} (attempt ${attempt + 1}/${maxRetries}) - ${error.message}`);
      }
      
    } catch (error) {
      const handledError = handleApiError(error, url);
      
      if (!shouldRetry(handledError, attempt, maxRetries)) {
        throw handledError;
      }
      
      lastError = handledError;
      
      if (config.enableDebugLogging) {
        console.warn(`⚠️ Network Error: ${url} (attempt ${attempt + 1}/${maxRetries})`);
      }
    }
    
    // Wait before retry (except on last attempt)
    if (attempt < maxRetries - 1) {
      const delay = calculateBackoffDelay(attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  // If we get here, all retries failed
  throw lastError || new Error('All retry attempts failed');
};

/**
 * Generic API request handler with consistent error handling
 */
const apiRequest = async <T>(
  endpoint: string, 
  options: RequestInit = {}
): Promise<T> => {
  const url = `${config.apiBaseUrl}${endpoint}`;
  
  try {
    const response = await fetchWithRetry(url, options);
    
    // Handle empty responses
    const contentType = response.headers.get('content-type');
    if (!contentType || !contentType.includes('application/json')) {
      const text = await response.text();
      if (!text) {
        return {} as T;
      }
      throw new ApiError(`Unexpected response format: ${contentType}`, response.status, url);
    }
    
    const data = await response.json();
    return data as T;
    
  } catch (error) {
    const handledError = handleApiError(error, url);
    logError(handledError, `API Request: ${endpoint}`);
    throw handledError;
  }
};

// ==================== API ENDPOINTS ====================

/**
 * Health check endpoint
 */
export const checkHealth = async (): Promise<{ status: string; timestamp: string; message: string }> => {
  return apiRequest('/health');
};

/**
 * Get all questions for an exam type
 */
export const getQuestions = async (examType: string): Promise<Question[]> => {
  if (!examType) {
    throw new ApiError('Exam type is required', 400, '/questions');
  }
  
  return apiRequest(`/questions/${encodeURIComponent(examType)}`);
};

/**
 * Get random questions for an exam
 */
export const getRandomQuestions = async (examType: string, count: number): Promise<Question[]> => {
  if (!examType) {
    throw new ApiError('Exam type is required', 400, '/questions/random');
  }
  
  if (count <= 0 || count > 100) {
    throw new ApiError('Question count must be between 1 and 100', 400, '/questions/random');
  }
  
  return apiRequest(`/questions/${encodeURIComponent(examType)}/random/${count}`);
};

/**
 * Start an exam session
 */
export const startExamSession = async (
  examType: string, 
  userId: string = 'anonymous', 
  questionCount: number = 20
): Promise<ExamSession> => {
  if (!examType) {
    throw new ApiError('Exam type is required', 400, '/exam/start');
  }
  
  return apiRequest('/exam/start', {
    method: 'POST',
    body: JSON.stringify({
      examType,
      userId,
      questionCount
    }),
  });
};

/**
 * Submit an answer
 */
export const submitAnswer = async (
  sessionId: string, 
  questionIndex: number, 
  selectedAnswer: number, 
  userId: string = 'anonymous'
): Promise<void> => {
  if (!sessionId) {
    throw new ApiError('Session ID is required', 400, '/exam/answer');
  }
  
  if (questionIndex < 0) {
    throw new ApiError('Question index must be non-negative', 400, '/exam/answer');
  }
  
  if (selectedAnswer < 0) {
    throw new ApiError('Selected answer must be non-negative', 400, '/exam/answer');
  }
  
  await apiRequest('/exam/answer', {
    method: 'POST',
    body: JSON.stringify({
      sessionId,
      userId,
      questionIndex,
      selectedAnswer
    }),
  });
};

/**
 * Complete exam and get results
 */
export const completeExam = async (sessionId: string, userId: string = 'anonymous'): Promise<ExamResult> => {
  if (!sessionId) {
    throw new ApiError('Session ID is required', 400, '/exam/complete');
  }
  
  return apiRequest('/exam/complete', {
    method: 'POST',
    body: JSON.stringify({
      sessionId,
      userId
    }),
  });
};

/**
 * Add a new question (admin function)
 */
export const addQuestion = async (question: Omit<Question, 'id'>): Promise<Question> => {
  if (!question.examType || !question.question || !question.options?.length) {
    throw new ApiError('Question data is incomplete', 400, '/questions');
  }
  
  return apiRequest('/questions', {
    method: 'POST',
    body: JSON.stringify(question),
  });
};

// ==================== UTILITY FUNCTIONS ====================

/**
 * Test API connectivity and return status
 */
export const testApiConnectivity = async (): Promise<{
  isOnline: boolean;
  latency?: number;
  error?: string;
}> => {
  const startTime = Date.now();
  
  try {
    await checkHealth();
    const latency = Date.now() - startTime;
    
    return {
      isOnline: true,
      latency
    };
  } catch (error) {
    const handledError = handleApiError(error, '/health');
    
    return {
      isOnline: false,
      error: handledError instanceof ApiError ? 
        handledError.getUserMessage() : 
        handledError.message
    };
  }
};

/**
 * Get API configuration for debugging
 */
export const getApiInfo = () => {
  return {
    baseUrl: config.apiBaseUrl,
    environment: config.environment,
    retryAttempts: config.retryAttempts,
    timeout: config.requestTimeout,
    debugLogging: config.enableDebugLogging
  };
};