import { render, screen } from '@testing-library/react';
import React from 'react';
import { App } from './App';

describe('App', () => {
  it('renders the hello dogs heading', () => {
    render(<App />);
    expect(screen.getByRole('heading', { name: /hello dogs~/i })).toBeInTheDocument();
  });
});
