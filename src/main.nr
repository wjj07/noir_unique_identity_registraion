// src/main.nr
// ZK Proof for Unique Identity Registration with Nullifier

use dep::std::hash::pedersen_hash;

// This circuit allows a user to prove they know a secret for an identity commitment
// and correctly compute a nullifier for a unique registration attempt.
// The actual registration commitment (e.g., hash(identity_commitment, public_identifier))
// would be formed and stored by an external system using the public outputs of this proof.

fn main(
    // === Private Inputs ===
    // Known only to the user.
    identity_secret: Field,         // The user's core private secret.
    identity_blinding_factor: Field,// Blinding factor for the identity commitment.

    // === Public Inputs ===
    // Provided by the user and verified/used by the system.
    public_identifier: pub Field,   // The chosen public identifier (e.g., username, partial pubkey).
    registration_epoch: pub Field,  // Current epoch/round for nullifier generation to prevent replay across epochs.
    
    // The Prover computes and outputs these. The circuit ensures they are correctly derived.
    // Alternatively, these could be public inputs claimed by the Prover, and the circuit
    // would verify them. Making them outputs is more natural for what the prover is "revealing".
    // For Nargo's current input/output model, we'll treat them as public inputs that the
    // circuit will constrain to be correctly computed from private inputs.
    claimed_identity_commitment: pub Field,
    claimed_nullifier: pub Field
) {
    // --- 1. Compute and Verify Identity Commitment ---
    // The user proves they know the secret and blinding factor for their identity commitment.
    let computed_identity_commitment = pedersen_hash([identity_secret, identity_blinding_factor]);
    constrain computed_identity_commitment == claimed_identity_commitment;

    // --- 2. Compute and Verify Nullifier ---
    // The nullifier is derived from the identity_secret and the current registration_epoch.
    // This ensures that for a given secret, a unique nullifier is generated for each epoch,
    // preventing replay of the registration proof with the same secret in the same epoch,
    // and also preventing using the same secret to register different public_identifiers
    // if the system checks nullifiers globally for a secret.
    let computed_nullifier = pedersen_hash([identity_secret, registration_epoch]);
    constrain computed_nullifier == claimed_nullifier;

    // --- Optional Additional Constraints ---
    // For example, ensure public_identifier is not zero or some other reserved value.
    // constrain public_identifier != 0; // Example: 0 might be an invalid identifier.

    // The external system would then:
    // 1. Verify this proof.
    // 2. Check if `claimed_nullifier` has been used before.
    // 3. Check if `public_identifier` has been registered before.
    // 4. If all checks pass, store `hash(claimed_identity_commitment, public_identifier)` 
    //    as the registration record and mark `claimed_nullifier` as spent.

    // println("Unique Identity Registration components proof validated.");
    // println("  Identity Commitment: {}", claimed_identity_commitment);
    // println("  Nullifier: {}", claimed_nullifier);
    // println("  For Public Identifier: {}", public_identifier);
    // println("  In Epoch: {}", registration_epoch);
}