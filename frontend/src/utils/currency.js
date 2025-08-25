export const formatIDR = (amount) => {
  const numAmount = parseFloat(amount || 0);
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(numAmount);
};

export const formatNumber = (amount) => {
  const numAmount = parseFloat(amount || 0);
  return numAmount.toLocaleString('id-ID');
};