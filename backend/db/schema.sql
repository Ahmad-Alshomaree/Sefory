CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    surname VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    license_number VARCHAR(100) NOT NULL,
    license_photo_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    cancellation_strikes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    model VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    plate_number VARCHAR(20) NOT NULL,
    color VARCHAR(50),
    year INT,
    photo_url TEXT,
    price NUMERIC(10,2),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE driver_cities (
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    PRIMARY KEY (driver_id, city_id)
);

CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id UUID NOT NULL REFERENCES passengers(id),
    driver_id UUID REFERENCES drivers(id),
    car_id UUID REFERENCES cars(id),
    trip_type VARCHAR(20) NOT NULL CHECK (trip_type IN ('family', 'individual')),
    departure_city_id INT NOT NULL REFERENCES cities(id),
    destination_city_id INT NOT NULL REFERENCES cities(id),
    pickup_map_link TEXT NOT NULL,
    dropoff_map_link TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'accepted', 'declined', 'started', 'completed', 'cancelled')),
    price NUMERIC(10,2),
    requested_at TIMESTAMP NOT NULL DEFAULT now(),
    accepted_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE TABLE driver_cancellations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    trip_id UUID NOT NULL REFERENCES trips(id),
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_type VARCHAR(20) NOT NULL CHECK (recipient_type IN ('passenger', 'driver')),
    recipient_id UUID NOT NULL,
    trip_id UUID REFERENCES trips(id),
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

INSERT INTO cities (name) VALUES
    ('Baghdad'),
    ('Basra'),
    ('Mosul'),
    ('Erbil'),
    ('Najaf'),
    ('Karbala'),
    ('Sulaymaniyah')
ON CONFLICT (name) DO NOTHING;
