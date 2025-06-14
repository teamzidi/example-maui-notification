import { ForexDataPoint, ForexData, ForexPair } from './types';

const generateRandomPrice = (basePrice: number): number => {
  // Generate a price within +/- 5% of the base price
  return basePrice * (1 + (Math.random() - 0.5) * 0.1);
};

const generateDataPoint = (date: Date, lastClose: number): ForexDataPoint => {
  const open = lastClose * (1 + (Math.random() - 0.5) * 0.02); // Open price within +/- 1% of last close
  const high = Math.max(open, open * (1 + Math.random() * 0.03)); // High is open or higher (up to 3% more)
  const low = Math.min(open, open * (1 - Math.random() * 0.03));   // Low is open or lower (up to 3% less)
  const close = generateRandomPrice(open); // Close price based on open

  return {
    date: date.toISOString().split('T')[0], // Format as YYYY-MM-DD
    open: parseFloat(open.toFixed(4)),
    high: parseFloat(high.toFixed(4)),
    low: parseFloat(low.toFixed(4)),
    close: parseFloat(close.toFixed(4)),
  };
};

const generateForexData = (pair: ForexPair, days: number): ForexData => {
  const data: ForexDataPoint[] = [];
  let currentDate = new Date();
  currentDate.setDate(currentDate.getDate() - days); // Start from 'days' ago

  // Initial base prices for pairs (can be adjusted)
  let lastClose = pair === 'MXN/JPY' ? 8.5 : 5.0;

  for (let i = 0; i < days; i++) {
    const newDataPoint = generateDataPoint(currentDate, lastClose);
    data.push(newDataPoint);
    lastClose = newDataPoint.close;
    currentDate.setDate(currentDate.getDate() + 1);
  }

  return {
    pair,
    data,
  };
};

// Generate data for 5 years (approx 365 * 5 days)
const MXN_JPY_DATA = generateForexData('MXN/JPY', 365 * 5 + 2); // Add a couple of extra for buffer
const ZAR_JPY_DATA = generateForexData('ZAR/JPY', 365 * 5 + 2);

export const dummyForexData: Record<ForexPair, ForexData> = {
  'MXN/JPY': MXN_JPY_DATA,
  'ZAR/JPY': ZAR_JPY_DATA,
};

export const getFilteredData = (pair: ForexPair, period: TimePeriod): ForexDataPoint[] => {
  const allData = dummyForexData[pair].data;
  const today = new Date();
  let startDate = new Date(today);

  switch (period) {
    case '10D':
      startDate.setDate(today.getDate() - 10);
      break;
    case '30D':
      startDate.setDate(today.getDate() - 30);
      break;
    case '6M':
      startDate.setMonth(today.getMonth() - 6);
      break;
    case '1Y':
      startDate.setFullYear(today.getFullYear() - 1);
      break;
    case '5Y':
      startDate.setFullYear(today.getFullYear() - 5);
      break;
    default:
      return allData; // Should not happen
  }

  const filterStartDateStr = startDate.toISOString().split('T')[0];
  return allData.filter(point => point.date >= filterStartDateStr);
};
