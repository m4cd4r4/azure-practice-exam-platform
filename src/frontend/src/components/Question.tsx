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
  onAnswer: (questionId: string, answerId: string) => void;
}

const Question: React.FC<QuestionProps> = ({ question, onAnswer }) => {
  return (
    <div className="bg-white p-4 rounded shadow">
      <p className="font-semibold mb-4">{question.text}</p>
      <div className="space-y-2">
        {question.options.map((option) => (
          <div key={option.id}>
            <label className="flex items-center space-x-2">
              <input
                type="radio"
                name={question.id}
                value={option.id}
                className="form-radio"
                onChange={() => onAnswer(question.id, option.id)}
              />
              <span>{option.text}</span>
            </label>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Question;
