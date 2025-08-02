import React, { useState } from 'react';
import ExamList from './components/ExamList';
import Exam from './components/Exam';

function App() {
  const [selectedExam, setSelectedExam] = useState<string | null>(null);

  return (
    <div className="flex flex-col min-h-screen bg-gray-100">
      <header className="bg-blue-600 text-white p-4 shadow-md">
        <div className="container mx-auto">
          <h1 className="text-2xl font-bold">Azure Practice Exams</h1>
          <p className="text-blue-100 text-sm mt-1">
            Master Azure certifications with real practice questions
          </p>
        </div>
      </header>
      
      <main className="flex-grow container mx-auto p-4">
        {selectedExam ? (
          <Exam 
            examType={selectedExam} 
            onBack={() => setSelectedExam(null)} 
          />
        ) : (
          <div>
            <div className="mb-6 text-center">
              <h2 className="text-3xl font-bold text-gray-800 mb-2">
                Choose Your Certification Path
              </h2>
              <p className="text-gray-600">
                Practice with real exam questions and get instant feedback
              </p>
            </div>
            <ExamList onSelectExam={setSelectedExam} />
          </div>
        )}
      </main>
      
      <footer className="bg-gray-800 text-white p-4 text-center">
        <div className="container mx-auto">
          <p>&copy; 2025 Azure Practice Exam Platform</p>
          <p className="text-gray-400 text-sm mt-1">
            Built with Azure Functions, React & TypeScript
          </p>
        </div>
      </footer>
    </div>
  );
}

export default App;
