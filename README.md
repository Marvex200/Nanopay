# Nanopay Smart Contract

Nanopay is a simple tipping contract for the Stacks blockchain. It allows users to tip creators in STX, tracks tip records, and maintains per-recipient totals. The contract includes admin controls to pause or unpause tipping.

## Features

- **Tip Creators:** Send STX tips to any principal address.
- **Track Tips:** Each tip is recorded with sender, recipient, amount, memo, and timestamp.
- **Totals:** View total STX received by any recipient.
- **Admin Controls:** Pause or unpause the contract to prevent or allow tipping.

## Contract Functions

### Public Functions

- `tip(recipient, amount, memo)`  
  Tip a recipient with a specified amount and optional memo.

- `set-paused(flag)`  
  Admin-only. Pause or unpause the contract.

### Read-Only Functions

- `get-tip(id)`  
  Get details of a specific tip by ID.

- `get-total-received(who)`  
  Get the total STX received by a recipient.

- `get-next-tip-id()`  
  Get the next tip ID.

- `is-paused()`  
  Check if the contract is currently paused.

## Usage

1. **Deploy the contract:**  
   Replace `CONTRACT-OWNER` with your principal address before deploying.

2. **Tip a creator:**  
   Call the `tip` function with the recipient's address, amount, and optional memo.

3. **Pause/Unpause:**  
   Only the contract owner can call `set-paused` to control tipping activity.

## Development

- Written in [Clarity](https://docs.stacks.co/docs/clarity-language/overview/).
- Compatible with Stacks Mainnet and Testnet.
- See `.gitignore` for recommended exclusions.


