import React, { useState, useEffect } from 'react';
import Question from './Question';
import { Question as QuestionType, getQuestions } from '../services/api';

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
  const [showResults, setShowResults] = useState(false);

  useEffect(() => {
    const initializeExam = async () => {
      try {
        setLoading(true);
        setError(null);

        // Get questions directly (bypass session management for now)
        const fetchedQuestions = await getQuestions(examType);
        
        if (fetchedQuestions && fetchedQuestions.length > 0) {
          // Filter out questions with invalid or empty options
          const validQuestions = fetchedQuestions.filter(question => 
            question.options && 
            Array.isArray(question.options) && 
            question.options.length > 0 &&
            question.question && 
            question.question.trim() !== ''
          );
          
          if (validQuestions.length > 0) {
            // Limit to 10 questions for better experience
            const limitedQuestions = validQuestions.slice(0, 10);
            setQuestions(limitedQuestions);
            console.log(`Loaded ${limitedQuestions.length} valid questions for ${examType}`);
            console.log('Filtered out invalid questions:', fetchedQuestions.length - validQuestions.length);
          } else {
            setError('No valid questions found for this exam type');
          }
        } else {
          setError('No questions found for this exam type');
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load exam');
        console.error('Error initializing exam:', err);
      } finally {
        setLoading(false);
      }
    };

    initializeExam();
  }, [examType]);

  const handleAnswer = (questionIndex: number, selectedAnswer: number) => {
    setAnswers((prevAnswers) => ({
      ...prevAnswers,
      [questionIndex]: selectedAnswer,
    }));
  };

  const handleNextQuestion = () => {
    if (currentQuestionIndex < questions.length - 1) {
      setCurrentQuestionIndex((prevIndex) => prevIndex + 1);
    } else {
      // Complete the exam
      completeExam();
    }
  };

  const handlePreviousQuestion = () => {
    if (currentQuestionIndex > 0) {
      setCurrentQuestionIndex((prevIndex) => prevIndex - 1);
    }
  };

  const completeExam = () => {
    setShowResults(true);
  };

  const calculateResults = () => {
    let correctCount = 0;
    const totalQuestions = questions.length;
    
    questions.forEach((question, index) => {
      const userAnswer = answers[index];
      if (userAnswer === question.correctAnswer) {
        correctCount++;
      }
    });
    
    const percentage = Math.round((correctCount / totalQuestions) * 100);
    return { correctCount, totalQuestions, percentage };
  };

  const restartExam = () => {
    setCurrentQuestionIndex(0);
    setAnswers({});
    setShowResults(false);
    setError(null);
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

  if (!questions || questions.length === 0) {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-yellow-800 mb-2">No Questions Available</h3>
        <p className="text-yellow-700 mb-4">
          No valid questions found for {examType}. Questions may not be loaded yet or may have formatting issues.
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

  if (showResults) {
    const { correctCount, totalQuestions, percentage } = calculateResults();
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
                {correctCount} / {totalQuestions}
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

          {/* Show detailed results */}
          <div className="mt-6">
            <h4 className="font-semibold text-gray-800 mb-3">Question Review:</h4>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {questions.map((question, index) => {
                const userAnswer = answers[index];
                const isCorrect = userAnswer === question.correctAnswer;
                
                return (
                  <div key={index} className={`p-3 rounded border ${isCorrect ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'}`}>
                    <div className="text-sm">
                      <strong>Q{index + 1}:</strong> {question.question}
                    </div>
                    <div className="text-xs mt-1">
                      <span className={`font-semibold ${isCorrect ? 'text-green-700' : 'text-red-700'}`}>
                        {isCorrect ? '✅ Correct' : '❌ Incorrect'}
                      </span>
                      {!isCorrect && userAnswer !== undefined && (
                        <span className="text-gray-600 ml-2">
                          Your answer: {question.options[userAnswer]} | Correct: {question.options[question.correctAnswer]}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="flex space-x-4 pt-4">
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

  // At this point, we know questions array exists and has valid items
  const currentQuestion = questions[currentQuestionIndex];
  const isLastQuestion = currentQuestionIndex === questions.length - 1;
  const hasAnsweredCurrent = answers[currentQuestionIndex] !== undefined;

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
        disabled={false}
      />

      {/* Question Info */}
      <div className="flex space-x-4 text-sm text-gray-600">
        <span>Category: {currentQuestion.category || 'General'}</span>
        <span>Difficulty: {currentQuestion.difficulty || 'Medium'}</span>
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
          disabled={!hasAnsweredCurrent}
          className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLastQuestion ? 'Complete Exam' : 'Next Question'}
        </button>
      </div>

      {/* Answer prompt */}
      {!hasAnsweredCurrent && (
        <div className="text-center text-gray-500 text-sm">
          Please select an answer to continue
        </div>
      )}
    </div>
  );
};

export default Exam;