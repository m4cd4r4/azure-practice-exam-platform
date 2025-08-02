// Error handling utilities for Azure Practice Exam Platform
// Provides consistent error management and user-friendly messages

/**
 * Custom API Error class with additional context
 */
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public endpoint: string,
    public originalError?: unknown
  ) {
    super(message);
    this.name = 'ApiError';
  }

  /**
   * Get user-friendly error message
   */
  getUserMessage(): string {
    switch (this.status) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication required. Please log in and try again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. We\'re working to fix this issue.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return this.message || 'An unexpected error occurred.';
    }
  }

  /**
   * Check if this is a temporary error that might succeed on retry
   */
  isRetryable(): boolean {
    return this.status >= 500 || this.status === 429;
  }
}

/**
 * Network connectivity error
 */
export class NetworkError extends Error {
  constructor(message: string = 'Network connection failed') {
    super(message);
    this.name = 'NetworkError';
  }

  getUserMessage(): string {
    return 'Unable to connect to the server. Please check your internet connection.';
  }

  isRetryable(): boolean {
    return true;
  }
}

/**
 * Handle various types of errors and convert to appropriate error objects
 */
export const handleApiError = (error: unknown, endpoint: string): ApiError | NetworkError => {
  // Handle Response object (from fetch)
  if (error instanceof Response) {
    return new ApiError(
      `API request failed: ${error.statusText}`,
      error.status,
      endpoint,
      error
    );
  }
  
  // Handle TypeError (usually network issues)
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return new NetworkError('Failed to connect to server');
  }
  
  // Handle generic Error objects
  if (error instanceof Error) {
    // Check if it's a network-related error
    if (error.message.includes('Network') || 
        error.message.includes('fetch') ||
        error.message.includes('CORS')) {
      return new NetworkError(error.message);
    }
    
    return new ApiError(error.message, 500, endpoint, error);
  }
  
  // Handle unknown errors
  return new ApiError('Unknown error occurred', 500, endpoint, error);
};

/**
 * Log errors appropriately based on environment
 */
export const logError = (error: ApiError | NetworkError, context?: string): void => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  if (isDevelopment) {
    console.group(`🚨 Error${context ? ` in ${context}` : ''}`);
    console.error('Error Type:', error.constructor.name);
    console.error('Message:', error.message);
    
    if (error instanceof ApiError) {
      console.error('Status:', error.status);
      console.error('Endpoint:', error.endpoint);
      console.error('Original Error:', error.originalError);
    }
    
    console.error('Stack:', error.stack);
    console.groupEnd();
  } else {
    // In production, log minimal information
    console.error(`Error: ${error.message}`);
  }
};

/**
 * Create user-facing error messages with optional technical details
 */
export const createErrorMessage = (
  error: ApiError | NetworkError,
  includeDetails: boolean = false
): { message: string; details?: string } => {
  const userMessage = error instanceof ApiError ? 
    error.getUserMessage() : 
    error.getUserMessage();
  
  const result: { message: string; details?: string } = {
    message: userMessage
  };
  
  if (includeDetails && process.env.NODE_ENV === 'development') {
    result.details = error.message;
  }
  
  return result;
};

/**
 * Determine if an operation should be retried based on the error
 */
export const shouldRetry = (
  error: ApiError | NetworkError,
  attemptNumber: number,
  maxAttempts: number = 3
): boolean => {
  if (attemptNumber >= maxAttempts) {
    return false;
  }
  
  return error instanceof ApiError ? 
    error.isRetryable() : 
    error.isRetryable();
};

/**
 * Calculate backoff delay for retry attempts
 */
export const calculateBackoffDelay = (attemptNumber: number): number => {
  // Exponential backoff: 1s, 2s, 4s, 8s...
  return Math.min(1000 * Math.pow(2, attemptNumber), 10000);
};