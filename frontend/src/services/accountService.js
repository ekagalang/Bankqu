import api from './api';

export const accountService = {
  getAll: () => api.get('/accounts'),
  
  create: (data) => api.post('/accounts', data),
  
  update: (id, data) => api.put(`/accounts/${id}`, data),
  
  delete: (id) => api.delete(`/accounts/${id}`),
  
  getById: (id) => api.get(`/accounts/${id}`)
};