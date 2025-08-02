import React from 'react';

interface Option {
  id: string;
  text: string;
}

interface QuestionProps {
  question: {
    id: string;
    text: string;
    options: Option[];
  };
  selectedAnswer?: string;
  onAnswer: (questionId: string, answerId: string) => void;
  disabled?: boolean;
}

const Question: React.FC<QuestionProps> = ({ question, selectedAnswer, onAnswer, disabled = false }) => {
  return (
    <div className="bg-white p-6 rounded-lg shadow-lg">
      <h3 className="text-lg font-semibold mb-4 text-gray-800">
        {question.text}
      </h3>
      <div className="space-y-3">
        {question.options.map((option) => (
          <div key={option.id} className="flex items-start">
            <label className="flex items-start space-x-3 cursor-pointer w-full p-3 rounded-lg hover:bg-gray-50 transition-colors">
              <input
                type="radio"
                name={question.id}
                value={option.id}
                checked={selectedAnswer === option.id}
                onChange={() => onAnswer(question.id, option.id)}
                disabled={disabled}
                className="mt-1 form-radio h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300"
              />
              <span className={`text-gray-700 leading-relaxed ${disabled ? 'opacity-50' : ''}`}>
                {option.text}
              </span>
            </label>
          </div>
        ))}
      </div>
      
      {disabled && (
        <div className="mt-4 text-sm text-gray-500 flex items-center">
          <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-2"></div>
          Saving your answer...
        </div>
      )}
    </div>
  );
};

export default Question;
