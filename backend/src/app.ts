import cors from 'cors';
import express from 'express';
import helmet from 'helmet';

import { errorHandler } from './middleware/errorHandler.js';
import { healthRouter } from './routes/health.js';
import { v1Router } from './routes/v1/index.js';

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());

  app.get('/', (_request, response) => {
    response.json({
      success: true,
      data: {
        name: 'iraq-ride-backend',
        version: '0.1.0',
      },
    });
  });

  app.use('/health', healthRouter);
  app.use('/api/v1', v1Router);

  app.use(errorHandler);

  return app;
}
