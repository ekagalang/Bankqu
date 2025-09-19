import api from './api';

export const transactionService = {
  getAll: (params = {}) => api.get('/transactions', { params }),
  
  create: (data) => api.post('/transactions', data),
  
  update: (id, data) => api.put(`/transactions/${id}`, data),
  
  delete: (id) => api.delete(`/transactions/${id}`),
  
  getById: (id) => api.get(`/transactions/${id}`),
  
  getSummary: (params = {}) => api.get('/transactions/summary', { params })
};