# matti-riddles

Simple & basic riddles script for QBCore/QBOX.

## Version

- **v1.1.0** — latest updates and improvements

## Highlights (recent changes)

- Added optional appearance/outfit support by `citizenid` (illenium-appearance/player_outfits fallback).
- Outfit fetch uses the database and prefers full skin JSON from `playerskins`, falling back to `player_outfits` components/props.
- Payment flow: configurable `Config.Price` and `Config.PriceMethod` (cash/bank) with server-side checks.
- Sequential progression: riddles must be completed in order; starting the first riddle can require payment.
- Fuzzy answer matching: tolerant checks and friendly "almost" hints for near-correct answers.
- Rewards support: gives configured rewards on completion; supports `ox_inventory` and `qb-inventory` (configurable).
- Target & interaction support: `ox_target` (default) and `qb-target` compatibility.
- Debug option prints the correct answer to the client console when `Config.Debug = true`.

## Features

- QB/QBX support
- Ped spawns with scenarios and optional clothing
- Target interaction via `ox_target` / `qb-target`
- Inventory rewards via `ox_inventory` / `qb-inventory`
- Configurable price/payment method
- Locales (English + Dutch included)

## Dependencies

- ox_lib
- ox_inventory (or qb-inventory if configured)
- ox_target or qb-target (for interaction)
- illenium-appearance (optional, for full skin support)
- oxmysql (server-side DB access for outfits)

## Installation / Notes

- Place the resource in your resources folder and start it from your server.cfg.
- Ensure `@ox_lib`, `ox_inventory` (or `qb-inventory`), `ox_target` (or `qb-target`), and `oxmysql` are available and started.
- Configure `Config.Price`, `Config.PriceMethod`, `Config.Riddles`, `Config.Rewards`, `Config.Target`, and `Config.Inventory` in `config.lua` to match your server setup.
- If using the `optionalClothing` citizenid feature, ensure your database has `playerskins` or `player_outfits` rows for the given citizenid.

## Locales

- English (`locales/en.json`) and Dutch (`locales/nl.json`) are included. Add or translate other languages as needed.

## Changelog

- v1.1.0: appearance/outfit support, payment flow, fuzzy-answer hints, sequential unlocks, rewards, MySQL outfit lookup, target + inventory compatibility.

## Preview

Start:

![image](https://github.com/user-attachments/assets/29ffb4b2-5938-462f-8e9e-000647ac21e0)

Price config:

![image](https://github.com/user-attachments/assets/6c90e9c4-ae66-4917-8a18-79ac0af16912)

Riddles:

![image](https://github.com/user-attachments/assets/0a209359-419a-4ba7-aa1e-a469c210fa78)

Inputs:

![image](https://github.com/user-attachments/assets/98777050-b167-4ac0-842f-80d3ea3719d5)

Wrong answer:

![image](https://github.com/user-attachments/assets/37861928-b9f8-4f38-baee-662d930ec0cd)

Debug answer:

![image](https://github.com/user-attachments/assets/082605f3-ec68-4204-9730-99d1abbe44a0)

Completing:

![image](https://github.com/user-attachments/assets/d33fad18-fa47-4efc-b5df-19203bf99ed1)
