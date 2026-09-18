import { Router } from 'express';
import { z } from 'zod';

import { authenticate, type AuthenticatedRequest } from '../../middleware/authenticate.js';
import { acceptTripRequest, createTrip, listTripsForUser, transitionTrip } from '../../services/trips.js';

export const tripsRouter = Router();

const createTripSchema = z.object({
  tripType: z.enum(['family', 'individual']),
  departureCityId: z.number().int().positive(),
  destinationCityId: z.number().int().positive(),
  pickupMapLink: z.string().url(),
  dropoffMapLink: z.string().url(),
});

const acceptTripSchema = z.object({
  carId: z.string().min(1),
  price: z.number().positive(),
});

const statusSchema = z.object({
  status: z.enum(['declined', 'started', 'completed', 'cancelled']),
});

tripsRouter.get('/', authenticate(), async (request: AuthenticatedRequest, response) => {
  const trips = await listTripsForUser(request.auth!.userId, request.auth!.role);

  response.json({
    success: true,
    data: trips,
  });
});

tripsRouter.post('/', authenticate('passenger'), async (request: AuthenticatedRequest, response) => {
  const parsed = createTripSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid trip request payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const trip = await createTrip({
    passengerId: request.auth!.userId,
    ...parsed.data,
  });

  response.status(201).json({
    success: true,
    data: trip,
  });
});

tripsRouter.post('/:tripId/accept', authenticate('driver'), async (request: AuthenticatedRequest, response) => {
  const parsed = acceptTripSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid accept payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const trip = await acceptTripRequest(String(request.params.tripId), request.auth!.userId, parsed.data.carId, parsed.data.price);

  if (!trip) {
    response.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'Trip not found or cannot be accepted',
      },
    });

    return;
  }

  response.json({ success: true, data: trip });
});

tripsRouter.patch('/:tripId/status', authenticate('driver'), async (request: AuthenticatedRequest, response) => {
  const parsed = statusSchema.safeParse(request.body);

  if (!parsed.success) {
    response.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid trip status payload',
        details: parsed.error.flatten(),
      },
    });

    return;
  }

  const trip = await transitionTrip(String(request.params.tripId), parsed.data.status);

  if (!trip) {
    response.status(404).json({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'Trip not found or cannot transition',
      },
    });

    return;
  }

  response.json({ success: true, data: trip });
});
