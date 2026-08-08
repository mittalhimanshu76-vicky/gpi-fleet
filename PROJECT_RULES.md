# GPI Fleet Project Rules

## 1. Product Direction

GPI Fleet is being developed as a commercial product.

It should also support the creation of a premium Notion Fleet Management OS.

## 2. Feature Evaluation

Before implementing a feature, evaluate:

- Does it solve a real customer problem?
- Would a business pay for it?
- Can it be represented in the Notion template?
- Does it improve differentiation?
- Is the development effort justified?

## 3. Stability

Never unnecessarily modify a working module.

Before major changes:

- Verify the current implementation.
- Make a Git checkpoint.
- Make the smallest reasonable change.

## 4. Testing

Before completing a milestone:

- Run flutter analyze.
- Test on a real Android device.
- Verify existing critical features.

## 5. Git

Every stable milestone must be committed.

Use meaningful commit messages.

Push stable milestones to the remote repository.

## 6. Architecture

Prefer:

- Models instead of uncontrolled Map<String, dynamic> usage.
- Separate services/repositories.
- Reusable widgets.
- Centralized constants.
- Clear module boundaries.

## 7. Business Data

Do not hardcode company-specific information when it should eventually be configurable.

## 8. UI

Follow Material 3.

Avoid unnecessary redesigns during active feature development.

Major UI redesigns should be planned as a dedicated milestone.

## 9. Reports

PDF and Excel exports should remain stable.

Do not modify reporting functionality unless there is a specific bug or planned improvement.

## 10. Commercialization

Each major module should eventually have:

- App implementation
- Documentation
- Notion equivalent
- Demo data
- Marketing screenshots
- Commercial positioning

## 11. Future Compatibility

Design database structures and modules so the application can eventually support:

- Cloud synchronization
- Multiple companies
- Multiple users
- Subscription plans
- White-label deployments
- APIs and integrations

## 12. Development Principle

Do not build features simply because they are technically interesting.

Build features that move the product toward becoming a useful and commercially viable Fleet Operating System.