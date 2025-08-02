import React, { useState, useEffect } from 'react';
import { checkHealth } from '../services/api';

const exams = [
  { 
    id: 'AZ-104', 
    name: 'AZ-104: Microsoft Azure Administrator',
    description: 'Manage Azure identities, governance, storage, compute, and virtual networks',
    difficulty: 'Intermediate',
    duration: '20 minutes',
    questions: '10 questions'
  },
  { 
    id: 'AZ-900', 
    name: 'AZ-900: Microsoft Azure Fundamentals',
    description: 'Learn cloud concepts, Azure services, security, and compliance',
    difficulty: 'Beginner',
    duration: '15 minutes',  
    questions: '10 questions'
  },
];

interface ExamListProps {
  onSelectExam: (examId: string) => void;
}

const ExamList: React.FC<ExamListProps> = ({ onSelectExam }) => {
  const [apiStatus, setApiStatus] = useState<'loading' | 'online' | 'offline'>('loading');

  useEffect(() => {
    const checkApiHealth = async () => {
      try {
        await checkHealth();
        setApiStatus('online');
      } catch (error) {
        setApiStatus('offline');
        console.error('API health check failed:', error);
      }
    };

    checkApiHealth();
  }, []);

  return (
    <div className="max-w-4xl mx-auto">
      {/* API Status */}
      <div className="mb-6">
        <div className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
          apiStatus === 'online' 
            ? 'bg-green-100 text-green-800' 
            : apiStatus === 'offline'
            ? 'bg-red-100 text-red-800'
            : 'bg-yellow-100 text-yellow-800'
        }`}>
          <div className={`w-2 h-2 rounded-full mr-2 ${
            apiStatus === 'online' 
              ? 'bg-green-500' 
              : apiStatus === 'offline'
              ? 'bg-red-500'
              : 'bg-yellow-500 animate-pulse'
          }`}></div>
          {apiStatus === 'loading' && 'Connecting to API...'}
          {apiStatus === 'online' && 'API Connected'}
          {apiStatus === 'offline' && 'API Offline - Using Demo Mode'}
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {exams.map((exam) => (
          <div
            key={exam.id}
            className="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow cursor-pointer border border-gray-200"
            onClick={() => onSelectExam(exam.id)}
          >
            <div className="mb-4">
              <h3 className="text-xl font-bold text-gray-800 mb-2">
                {exam.name}
              </h3>
              <p className="text-gray-600 text-sm leading-relaxed">
                {exam.description}
              </p>
            </div>

            <div className="space-y-2 mb-4">
              <div className="flex items-center text-sm text-gray-500">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                <span className={`px-2 py-1 rounded text-xs font-medium ${
                  exam.difficulty === 'Beginner' 
                    ? 'bg-green-100 text-green-800'
                    : 'bg-blue-100 text-blue-800'
                }`}>
                  {exam.difficulty}
                </span>
              </div>

              <div className="flex items-center text-sm text-gray-500">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                {exam.duration}
              </div>

              <div className="flex items-center text-sm text-gray-500">
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                {exam.questions}
              </div>
            </div>

            <button
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors font-medium"
              onClick={(e) => {
                e.stopPropagation();
                onSelectExam(exam.id);
              }}
            >
              Start Practice Exam
            </button>
          </div>
        ))}
      </div>

      {/* Info Section */}
      <div className="mt-8 bg-blue-50 rounded-lg p-6 border border-blue-200">
        <h4 className="font-semibold text-blue-800 mb-2">📚 How it works</h4>
        <ul className="text-blue-700 text-sm space-y-1">
          <li>• Select an exam to start practicing</li>
          <li>• Answer questions and get instant feedback</li>
          <li>• Review your score and see detailed explanations</li>
          <li>• Retake exams to improve your knowledge</li>
        </ul>
      </div>
    </div>
  );
};

export default ExamList;
