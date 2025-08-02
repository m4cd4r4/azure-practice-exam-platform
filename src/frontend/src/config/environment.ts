// Environment configuration for Azure Practice Exam Platform
// Centralizes API endpoints and environment-specific settings

interface EnvironmentConfig {
  apiBaseUrl: string;
  environment: 'development' | 'production' | 'testing';
  enableDebugLogging: boolean;
  retryAttempts: number;
  requestTimeout: number;
  features: {
    enableOfflineMode: boolean;
    enableAnalytics: boolean;
    enableBetaFeatures: boolean;
  };
}

/**
 * Main configuration object
 * Reads from environment variables with sensible defaults
 */
export const config: EnvironmentConfig = {
  // API Configuration
  apiBaseUrl: process.env.REACT_APP_API_BASE_URL || 
    'https://azpracticeexam-dev-functions.azurewebsites.net/api',
  
  // Environment Detection
  environment: (process.env.NODE_ENV as 'development' | 'production') || 'development',
  
  // Debug Settings
  enableDebugLogging: process.env.NODE_ENV === 'development' || 
    process.env.REACT_APP_DEBUG === 'true',
  
  // Network Configuration
  retryAttempts: parseInt(process.env.REACT_APP_RETRY_ATTEMPTS || '3'),
  requestTimeout: parseInt(process.env.REACT_APP_REQUEST_TIMEOUT || '10000'),
  
  // Feature Flags
  features: {
    enableOfflineMode: process.env.REACT_APP_ENABLE_OFFLINE === 'true',
    enableAnalytics: process.env.REACT_APP_ENABLE_ANALYTICS === 'true',
    enableBetaFeatures: process.env.REACT_APP_ENABLE_BETA === 'true',
  },
};

/**
 * Utility function to log configuration in development
 */
export const logConfiguration = (): void => {
  if (config.enableDebugLogging) {
    console.group('🔧 Azure Practice Exam - Configuration');
    console.log('Environment:', config.environment);
    console.log('API Base URL:', config.apiBaseUrl);
    console.log('Debug Logging:', config.enableDebugLogging);
    console.log('Retry Attempts:', config.retryAttempts);
    console.log('Request Timeout:', config.requestTimeout);
    console.log('Features:', config.features);
    console.groupEnd();
  }
};

/**
 * Validate that required configuration is present
 */
export const validateConfiguration = (): boolean => {
  const requiredFields = [
    config.apiBaseUrl,
  ];
  
  const isValid = requiredFields.every(field => 
    field !== undefined && field !== null && field !== ''
  );
  
  if (!isValid && config.enableDebugLogging) {
    console.error('❌ Configuration validation failed');
  }
  
  return isValid;
};

export default config;