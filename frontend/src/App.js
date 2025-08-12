import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import Login from './components/Login';
import FinanceApp from './components/FinanceApp'; // Main app component
import './index.css';

// src/App.js (lanjutan)
const ProtectedRoute = ({ children }) => {
 const { user, loading } = useAuth();
 
 if (loading) {
   return <div>Loading...</div>;
 }
 
 return user ? children : <Navigate to="/login" />;
};

function App() {
 return (
   <AuthProvider>
     <Router>
       <Routes>
         <Route path="/login" element={<Login />} />
         <Route path="/dashboard" element={
           <ProtectedRoute>
             <FinanceApp />
           </ProtectedRoute>
         } />
         <Route path="/" element={<Navigate to="/dashboard" />} />
       </Routes>
     </Router>
   </AuthProvider>
 );
}

export default App;