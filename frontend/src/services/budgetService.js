import api from './api';

export const budgetService = {
  getAll: () => api.get('/budgets'),
  
  create: (data) => api.post('/budgets', data),
  
  update: (id, data) => api.put(`/budgets/${id}`, data),
  
  delete: (id) => api.delete(`/budgets/${id}`)
};