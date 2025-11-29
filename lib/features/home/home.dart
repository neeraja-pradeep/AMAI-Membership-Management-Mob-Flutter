/// Home feature barrel export file
/// Exports all public APIs for the home feature
library home;

// Domain entities
export 'domain/entities/membership_card.dart';

// Application providers (only public providers)
export 'application/providers/home_providers.dart'
    show membershipStateProvider, MembershipNotifier;
export 'application/states/membership_state.dart';

// Presentation
export 'presentation/screens/home_screen.dart';
export 'presentation/components/membership_card_widget.dart';
export 'presentation/components/status_badge.dart';
