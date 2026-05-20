import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

export const REQUEST_ID_HEADER = 'x-request-id';
export const REQUEST_ID_PROP = 'requestId';

/**
 * Express compatible regex for a UUID v4. Used to validate
 * incoming `X-Request-Id` headers; values that don't match are replaced
 * to avoid log injection or unbounded id length.
 */
const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

/**
 * Loose id allow-list: alphanumeric, dash, underscore. Up to 64 chars.
 * Tolerates upstream gateways that mint their own non-UUID ids.
 */
const SAFE_ID = /^[A-Za-z0-9_-]{8,64}$/;

declare global {
  namespace Express {
    interface Request {
      requestId?: string;
    }
  }
}

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    const incoming = req.header(REQUEST_ID_HEADER);
    const id = incoming && (UUID_V4.test(incoming) || SAFE_ID.test(incoming))
      ? incoming
      : uuidv4();

    (req as Request).requestId = id;
    res.setHeader(REQUEST_ID_HEADER, id);
    next();
  }
}

/**
 * Functional variant for use outside NestJS DI (e.g. early bootstrap or
 * tests). Equivalent semantics to `RequestIdMiddleware`.
 */
export function requestIdMiddleware() {
  return (req: Request, res: Response, next: NextFunction): void => {
    const incoming = req.header(REQUEST_ID_HEADER);
    const id = incoming && (UUID_V4.test(incoming) || SAFE_ID.test(incoming))
      ? incoming
      : uuidv4();
    (req as Request).requestId = id;
    res.setHeader(REQUEST_ID_HEADER, id);
    next();
  };
}
