import type { NextFunction, Request, Response } from 'express';

import { verifyAccessToken } from '../auth/jwt.js';

export interface AuthenticatedRequest extends Request {
  auth?: {
    userId: string;
    role: 'passenger' | 'driver';
  };
}

export function authenticate(requiredRole?: 'passenger' | 'driver') {
  return (request: AuthenticatedRequest, response: Response, next: NextFunction) => {
    const header = request.headers.authorization;

    if (!header?.startsWith('Bearer ')) {
      response.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing bearer token',
        },
      });
      return;
    }

    try {
      const token = header.slice('Bearer '.length);
      const payload = verifyAccessToken(token);

      if (requiredRole && payload.role !== requiredRole) {
        response.status(403).json({
          success: false,
          error: {
            code: 'FORBIDDEN',
            message: 'Insufficient permissions',
          },
        });
        return;
      }

      request.auth = {
        userId: payload.sub,
        role: payload.role,
      };

      next();
    } catch {
      response.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Invalid bearer token',
        },
      });
    }
  };
}
