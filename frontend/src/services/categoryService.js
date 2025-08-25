import api from './api';

export const categoryService = {
  getAll: (params = {}) => api.get('/categories', { params }),
  
  create: (data) => api.post('/categories', data),
  
  update: (id, data) => api.put(`/categories/${id}`, data),
  
  delete: (id) => api.delete(`/categories/${id}`),
  
  getById: (id) => api.get(`/categories/${id}`)
};