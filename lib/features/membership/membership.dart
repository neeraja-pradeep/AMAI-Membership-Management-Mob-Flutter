/// Membership feature barrel export
/// Exports all public APIs for the membership feature
library membership;

// Domain - Entities
export 'domain/entities/membership_status.dart';

// Domain - Repository interface
export 'domain/repositories/membership_repository.dart';

// Application - Providers (only public state providers)
export 'application/providers/membership_providers.dart'
    show membershipScreenStateProvider;

// Application - States
export 'application/states/membership_screen_state.dart';

// Presentation - Screens
export 'presentation/screens/membership_screen.dart';

// Presentation - Components
export 'presentation/components/current_status_card.dart';
