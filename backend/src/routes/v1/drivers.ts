import { Router } from 'express';
import { z } from 'zod';

import { authenticate, type AuthenticatedRequest } from '../../middleware/authenticate.js';
import { addDriverCar, getDriverProfile, searchDrivers, setDriverAllowedCities } from '../../services/drivers.js';

export const driversRouter = Router();

const driverCitiesSchema = z.object({
  cityIds: z.array(z.number().int().positive()).min(1),
});

const carSchema = z.object({
  model: z.string().min(1),
  name: z.string().min(1).optional(),
  plateNumber: z.string().min(1),
  color: z.string().min(1).optional(),
  year: z.number().int().positive().optional(),
  photoUrl: z.string().url().optional(),
  price: z.number().positive().optional(),
});

const routeSearchSchema = z.object({
  departureCityId: z.coerce.number().int().positive(),
  destinationCityId: z.coerce.number().int().positive(),
});

driversRouter.get('/search', async (request, response) => {
  const parsed = routeSearchSchema.safeParse(request.query);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid driver search query',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const drivers = await searchDrivers(parsed.data.departureCityId, parsed.data.destinationCityId);

  response.json({ success: true, data: drivers });
});

driversRouter.get('/me', authenticate('driver'), async (request: AuthenticatedRequest, response) => {
  const profile = await getDriverProfile(request.auth!.userId);

  if (!profile) {
    response.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'Driver profile not found',
      },
    });

    return;
  }

  response.json({ success: true, data: profile });
});

driversRouter.post('/me/cars', authenticate('driver'), async (request: AuthenticatedRequest, response) => {
  const parsed = carSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid car payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const car = await addDriverCar({
    driverId: request.auth!.userId,
    ...parsed.data,
  });

  response.status(201).json({ success: true, data: car });
});

driversRouter.put('/me/cities', authenticate('driver'), async (request: AuthenticatedRequest, response) => {
  const parsed = driverCitiesSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid driver cities payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const cityIds = await setDriverAllowedCities({
    driverId: request.auth!.userId,
    cityIds: parsed.data.cityIds,
  });

  response.json({ success: true, data: { cityIds } });
});
