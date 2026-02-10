preset: ts-jest
testEnvironment: node
roots:
  - '<rootDir>/src'
  - '<rootDir>/tests'
testMatch:
  - '**/__tests__/**/*.ts'
  - '**/?(*.)+(spec|test).ts'
collectCoverageFrom:
  - 'src/**/*.ts'
  - '!src/**/*.d.ts'
  - '!src/**/*.interface.ts'
  - '!src/main.ts'
coverageThreshold:
  branches: 80
  functions: 80
  lines: 80
  statements: 80
coverageReporters:
  - text
  - lcov
  - html
