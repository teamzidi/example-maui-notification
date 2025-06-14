export interface ForexDataPoint {
  date: string; // YYYY-MM-DD
  open: number;
  high: number;
  low: number;
  close: number;
}

export type ForexPair = 'MXN/JPY' | 'ZAR/JPY';

export interface ForexData {
  pair: ForexPair;
  data: ForexDataPoint[];
}

export type TimePeriod = '10D' | '30D' | '6M' | '1Y' | '5Y';
