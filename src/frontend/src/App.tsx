import React, { useState } from 'react';
import ExamList from './components/ExamList';
import Exam from './components/Exam';

function App() {
  const [selectedExam, setSelectedExam] = useState<string | null>(null);

  return (
    <div className="flex flex-col min-h-screen bg-gray-100">
      <header className="bg-blue-600 text-white p-4 shadow-md">
        <h1 className="text-2xl font-bold">Azure Practice Exams</h1>
      </header>
      <main className="flex-grow container mx-auto p-4">
        {selectedExam ? (
          <Exam />
        ) : (
          <ExamList onSelectExam={setSelectedExam} />
        )}
      </main>
      <footer className="bg-gray-800 text-white p-4 text-center">
        <p>&copy; 2025 Azure Practice Exam Platform</p>
      </footer>
    </div>
  );
}

export default App;
