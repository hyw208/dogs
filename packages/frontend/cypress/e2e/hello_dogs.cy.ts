describe('Hello Dogs UI', () => {
  it('shows the greeting', () => {
    cy.visit('/');
    cy.contains('Hello dogs~').should('be.visible');
  });

  it('shows Login and Walk buttons', () => {
    cy.visit('/');
    cy.contains('button', 'Login').should('be.visible');
    cy.contains('button', 'Walk').should('be.visible');
  });
});
