import { Router } from 'express';
import { z } from 'zod';

import { loginDriver, loginPassenger, registerDriver, registerPassenger } from '../../auth/authService.js';

export const authRouter = Router();

const loginSchema = z.object({
  phoneNumber: z.string().min(5),
  password: z.string().min(6),
});

const passengerRegisterSchema = loginSchema.extend({
  fullName: z.string().min(2),
});

const driverRegisterSchema = loginSchema.extend({
  fullName: z.string().min(2),
  surname: z.string().min(2),
  licenseNumber: z.string().min(3),
  licensePhotoUrl: z.string().url().optional(),
});

authRouter.post('/passengers/register', async (request, response) => {
  const parsed = passengerRegisterSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid passenger registration payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  try {
    const session = await registerPassenger(parsed.data);
    response.status(201).json({ success: true, data: session });
  } catch (error) {
    response.status(400).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: error instanceof Error ? error.message : 'Passenger registration failed',
      },
    });
  }
});

authRouter.post('/passengers/login', async (request, response) => {
  const parsed = loginSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid passenger login payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  try {
    const session = await loginPassenger(parsed.data);
    response.status(200).json({ success: true, data: session });
  } catch (error) {
    response.status(401).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: error instanceof Error ? error.message : 'Passenger login failed',
      },
    });
  }
});

authRouter.post('/drivers/register', async (request, response) => {
  const parsed = driverRegisterSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid driver registration payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  try {
    const session = await registerDriver(parsed.data);
    response.status(201).json({ success: true, data: session });
  } catch (error) {
    response.status(400).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: error instanceof Error ? error.message : 'Driver registration failed',
      },
    });
  }
});

authRouter.post('/drivers/login', async (request, response) => {
  const parsed = loginSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid driver login payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  try {
    const session = await loginDriver(parsed.data);
    response.status(200).json({ success: true, data: session });
  } catch (error) {
    response.status(401).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: error instanceof Error ? error.message : 'Driver login failed',
      },
    });
  }
});
