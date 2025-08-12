import api from './api';

export const investmentService = {
  getAll: () => api.get('/investments'),
  
  create: (data) => api.post('/investments', data),
  
  update: (id, data) => api.put(`/investments/${id}`, data),
  
  delete: (id) => api.delete(`/investments/${id}`),
  
  updatePrices: (investments) => api.patch('/investments/update-prices', { investments })
};