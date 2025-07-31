import React, { useState } from 'react';
import Question from './Question';

const sampleQuestions = [
  {
    id: 'q1',
    text: 'What is the default level of access for a user to a resource in Azure?',
    options: [
      { id: 'a', text: 'Reader' },
      { id: 'b', text: 'Contributor' },
      { id: 'c', text: 'Owner' },
      { id: 'd', text: 'No access' },
    ],
    correctAnswer: 'd',
  },
  {
    id: 'q2',
    text: 'Which Azure service is used to build, train, and deploy machine learning models?',
    options: [
      { id: 'a', text: 'Azure Functions' },
      { id: 'b', text: 'Azure Machine Learning' },
      { id: 'c', text: 'Azure Logic Apps' },
      { id: 'd', text: 'Azure Cognitive Services' },
    ],
    correctAnswer: 'b',
  },
];

const Exam = () => {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<{ [key: string]: string }>({});

  const handleAnswer = (questionId: string, answerId: string) => {
    setAnswers((prevAnswers) => ({
      ...prevAnswers,
      [questionId]: answerId,
    }));
  };

  const handleNextQuestion = () => {
    setCurrentQuestionIndex((prevIndex) => prevIndex + 1);
  };

  const currentQuestion = sampleQuestions[currentQuestionIndex];

  const calculateScore = () => {
    let score = 0;
    sampleQuestions.forEach((question) => {
      if (answers[question.id] === question.correctAnswer) {
        score++;
      }
    });
    return score;
  };

  return (
    <div>
      {currentQuestion ? (
        <>
          <Question question={currentQuestion} onAnswer={handleAnswer} />
          <button
            onClick={handleNextQuestion}
            className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Next Question
          </button>
        </>
      ) : (
        <div>
          <h3 className="text-lg font-semibold">Exam Complete</h3>
          <p>
            You scored {calculateScore()} out of {sampleQuestions.length}
          </p>
        </div>
      )}
    </div>
  );
};

export default Exam;
