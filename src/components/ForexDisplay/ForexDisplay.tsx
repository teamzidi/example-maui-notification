import React, { useState, useEffect } from 'react';
import { ForexDataPoint, ForexPair, TimePeriod } from './types';
import { getFilteredData, dummyForexData } from './dummyData';
import './ForexDisplay.css';

const ForexDisplay: React.FC = () => {
  const [selectedPair, setSelectedPair] = useState<ForexPair>('MXN/JPY');
  const [selectedPeriod, setSelectedPeriod] = useState<TimePeriod>('1Y');
  const [displayData, setDisplayData] = useState<ForexDataPoint[]>([]);

  useEffect(() => {
    setDisplayData(getFilteredData(selectedPair, selectedPeriod));
  }, [selectedPair, selectedPeriod]);

  const handlePairChange = (pair: ForexPair) => {
    setSelectedPair(pair);
  };

  const handlePeriodChange = (period: TimePeriod) => {
    setSelectedPeriod(period);
  };

  const timePeriods: TimePeriod[] = ['10D', '30D', '6M', '1Y', '5Y'];
  const forexPairs: ForexPair[] = ['MXN/JPY', 'ZAR/JPY'];

  return (
    <div className="forex-display-container">
      <h2>Exchange Rate Charts</h2>

      <div className="controls-section">
        <div className="pair-selector">
          <h3>Select Currency Pair:</h3>
          {forexPairs.map(pair => (
            <button
              key={pair}
              onClick={() => handlePairChange(pair)}
              className={selectedPair === pair ? 'active' : ''}
            >
              {pair}
            </button>
          ))}
        </div>

        <div className="period-selector">
          <h3>Select Period:</h3>
          {timePeriods.map(period => (
            <button
              key={period}
              onClick={() => handlePeriodChange(period)}
              className={selectedPeriod === period ? 'active' : ''}
            >
              {period}
            </button>
          ))}
        </div>
      </div>

      <div className="chart-section">
        <h3>{selectedPair} - {selectedPeriod}</h3>
        {/* Placeholder for the chart */}
        <div className="chart-placeholder">
          <p>Chart for {selectedPair} will be displayed here.</p>
          <p>{displayData.length} data points</p>
          {/* Basic data display for now */}
          <pre style={{ textAlign: 'left', maxHeight: '200px', overflowY: 'auto', background: '#f0f0f0', padding: '10px'}}>
            {displayData.map(d => `${d.date} O:${d.open} H:${d.high} L:${d.low} C:${d.close}`).join('\n')}
          </pre>
        </div>
      </div>

      {/* Placeholder for ZAR/JPY chart if needed, or a single chart that updates */}
      {/* For simplicity, we'll use one chart placeholder that updates based on selectedPair */}
    </div>
  );
};

export default ForexDisplay;
