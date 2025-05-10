# Noir ZK Proof of Unique Identity Registration

This project demonstrates a Zero-Knowledge proof using Noir for a unique identity registration system. The goal is to allow users to register a public identifier (like a username) by proving knowledge of an associated secret, while also generating a unique nullifier to prevent duplicate registrations with the same underlying secret identity. This is a foundational component for building Sybil-resistant and privacy-preserving identity systems.

## Core Concept

A user wants to register a `public_identifier`. To do so privately and uniquely, they:
1.  Possess a private `identity_secret`.
2.  Derive an `identity_commitment` = `hash(identity_secret, blinding_factor)`. This commitment can be used to link future actions without revealing the secret.
3.  Derive a `nullifier` = `hash(identity_secret, registration_epoch)`. The `registration_epoch` is a public value (e.g., current timestamp or block number) that ensures the nullifier is unique per epoch for a given secret.

The ZK circuit allows the user to prove:
*   They correctly computed their `identity_commitment` from their private `identity_secret` and `blinding_factor`.
*   They correctly computed their `nullifier` from their private `identity_secret` and the public `registration_epoch`.

An external system (e.g., a smart contract) would then:
1.  Verify the ZK proof.
2.  Check if the `public_identifier` is already taken.
3.  Check if the computed `nullifier` has already been spent/recorded.
4.  If all checks pass, record the registration (e.g., by storing `hash(identity_commitment, public_identifier)`) and mark the `nullifier` as spent.

This ensures that each secret can only be used to register once per epoch (or globally, if epochs are not reset for nullifiers), preventing a single user from creating multiple identities with the same secret.

## Project Structure