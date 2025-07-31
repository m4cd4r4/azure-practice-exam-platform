import React from 'react';

const exams = [
  { id: 'az-104', name: 'AZ-104: Microsoft Azure Administrator' },
  { id: 'az-900', name: 'AZ-900: Microsoft Azure Fundamentals' },
];

interface ExamListProps {
  onSelectExam: (examId: string) => void;
}

const ExamList: React.FC<ExamListProps> = ({ onSelectExam }) => {
  return (
    <div>
      <h3 className="text-lg font-semibold mb-2">Available Exams</h3>
      <ul className="space-y-2">
        {exams.map((exam) => (
          <li key={exam.id}>
            <button
              onClick={() => onSelectExam(exam.id)}
              className="w-full text-left p-2 bg-white rounded shadow hover:bg-blue-50"
            >
              {exam.name}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ExamList;
