import React, { useState, useEffect } from 'react';
import Question from './Question';
import { Question as QuestionType, getRandomQuestions, startExamSession, submitAnswer, completeExam, ExamSession, ExamResult } from '../services/api';

interface ExamProps {
  examType: string;
  onBack: () => void;
}

const Exam: React.FC<ExamProps> = ({ examType, onBack }) => {
  const [questions, setQuestions] = useState<QuestionType[]>([]);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<{ [key: number]: number }>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [examSession, setExamSession] = useState<ExamSession | null>(null);
  const [examResult, setExamResult] = useState<ExamResult | null>(null);
  const [submittingAnswer, setSubmittingAnswer] = useState(false);

  useEffect(() => {
    const initializeExam = async () => {
      try {
        setLoading(true);
        setError(null);

        // Start exam session first
        const session = await startExamSession(examType, 'anonymous', 10);
        setExamSession(session);

        // Get questions for this exam type
        const fetchedQuestions = await getRandomQuestions(examType, 10);
        setQuestions(fetchedQuestions);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load exam');
        console.error('Error initializing exam:', err);
      } finally {
        setLoading(false);
      }
    };

    initializeExam();
  }, [examType]);

  const handleAnswer = async (questionIndex: number, selectedAnswer: number) => {
    setAnswers((prevAnswers) => ({
      ...prevAnswers,
      [questionIndex]: selectedAnswer,
    }));

    // Submit answer to API
    if (examSession) {
      try {
        setSubmittingAnswer(true);
        await submitAnswer(examSession.sessionId, questionIndex, selectedAnswer);
      } catch (err) {
        console.error('Error submitting answer:', err);
        // Don't show error to user for individual answer submissions
      } finally {
        setSubmittingAnswer(false);
      }
    }
  };

  const handleNextQuestion = () => {
    if (currentQuestionIndex < questions.length - 1) {
      setCurrentQuestionIndex((prevIndex) => prevIndex + 1);
    } else {
      // Complete the exam
      completeExamSession();
    }
  };

  const handlePreviousQuestion = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex((prevIndex) => prevIndex - 1);
    }
  };

  const completeExamSession = async () => {
    if (!examSession) return;

    try {
      setLoading(true);
      const result = await completeExam(examSession.sessionId);
      setExamResult(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to complete exam');
      console.error('Error completing exam:', err);
    } finally {
      setLoading(false);
    }
  };

  const restartExam = () => {
    setQuestions([]);
    setCurrentQuestionIndex(0);
    setAnswers({});
    setExamSession(null);
    setExamResult(null);
    setError(null);
    
    // Re-initialize
    const initializeExam = async () => {
      try {
        setLoading(true);
        const session = await startExamSession(examType, 'anonymous', 10);
        setExamSession(session);
        const fetchedQuestions = await getRandomQuestions(examType, 10);
        setQuestions(fetchedQuestions);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to restart exam');
      } finally {
        setLoading(false);
      }
    };
    initializeExam();
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        <span className="ml-4 text-lg">Loading exam...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-red-800 mb-2">Error Loading Exam</h3>
        <p className="text-red-700 mb-4">{error}</p>
        <div className="space-x-4">
          <button
            onClick={restartExam}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            Try Again
          </button>
          <button
            onClick={onBack}
            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
          >
            Back to Exams
          </button>
        </div>
      </div>
    );
  }

  if (examResult) {
    const percentage = Math.round((examResult.correctAnswers / examResult.totalQuestions) * 100);
    const passed = percentage >= 70;

    return (
      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h3 className="text-2xl font-bold mb-4">Exam Complete! 🎉</h3>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-blue-50 p-4 rounded">
              <h4 className="font-semibold text-blue-800">Score</h4>
              <p className="text-2xl font-bold text-blue-600">{percentage}%</p>
            </div>
            <div className="bg-green-50 p-4 rounded">
              <h4 className="font-semibold text-green-800">Correct Answers</h4>
              <p className="text-2xl font-bold text-green-600">
                {examResult.correctAnswers} / {examResult.totalQuestions}
              </p>
            </div>
          </div>
          
          <div className={`p-4 rounded-lg ${passed ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            <h4 className="font-semibold">
              {passed ? '✅ Congratulations! You passed!' : '❌ Keep studying! You can do better!'}
            </h4>
            <p className="text-sm mt-1">
              {passed 
                ? 'You scored above the 70% passing threshold.' 
                : 'You need 70% or higher to pass. Review the topics and try again!'}
            </p>
          </div>

          <div className="flex space-x-4">
            <button
              onClick={restartExam}
              className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Take Again
            </button>
            <button
              onClick={onBack}
              className="px-6 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
            >
              Back to Exams
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (questions.length === 0) {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-yellow-800 mb-2">No Questions Available</h3>
        <p className="text-yellow-700 mb-4">
          No questions found for {examType}. Questions may not be loaded yet.
        </p>
        <button
          onClick={onBack}
          className="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700"
        >
          Back to Exams
        </button>
      </div>
    );
  }

  const currentQuestion = questions[currentQuestionIndex];
  const isLastQuestion = currentQuestionIndex === questions.length - 1;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <button
          onClick={onBack}
          className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
        >
          ← Back to Exams
        </button>
        <div className="text-sm text-gray-600">
          Question {currentQuestionIndex + 1} of {questions.length}
        </div>
      </div>

      {/* Progress Bar */}
      <div className="w-full bg-gray-200 rounded-full h-2">
        <div
          className="bg-blue-600 h-2 rounded-full transition-all duration-300"
          style={{ width: `${((currentQuestionIndex + 1) / questions.length) * 100}%` }}
        ></div>
      </div>

      {/* Question */}
      <Question
        question={{
          id: currentQuestion.id,
          text: currentQuestion.question,
          options: currentQuestion.options.map((option, index) => ({
            id: index.toString(),
            text: option
          }))
        }}
        selectedAnswer={answers[currentQuestionIndex]?.toString()}
        onAnswer={(questionId: string, answerId: string) => 
          handleAnswer(currentQuestionIndex, parseInt(answerId))
        }
        disabled={submittingAnswer}
      />

      {/* Question Info */}
      <div className="flex space-x-4 text-sm text-gray-600">
        <span>Category: {currentQuestion.category}</span>
        <span>Difficulty: {currentQuestion.difficulty}</span>
      </div>

      {/* Navigation */}
      <div className="flex justify-between">
        <button
          onClick={handlePreviousQuestion}
          disabled={currentQuestionIndex === 0}
          className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Previous
        </button>
        
        <button
          onClick={handleNextQuestion}
          disabled={submittingAnswer}
          className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {submittingAnswer ? 'Saving...' : isLastQuestion ? 'Complete Exam' : 'Next Question'}
        </button>
      </div>
    </div>
  );
};

export default Exam;
