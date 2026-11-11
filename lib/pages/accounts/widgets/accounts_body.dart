import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/accounts/widgets/account_section_label.dart';
import 'package:money_manager/pages/accounts/widgets/account_sliver.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountsBody extends StatelessWidget {
  const AccountsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (state.error == AccountsError.archiveBlocked) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.archiveBlocked)));
        }
      },
      builder: (context, overview) {
        if (overview.assets.isEmpty && overview.liabilities.isEmpty) {
          return Center(child: Text(l10n.emptyAccounts));
        }
        final locale = Localizations.localeOf(context).toString();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.netWorth,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatMinor(overview.netWorth, locale: locale),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (overview.assets.isNotEmpty) ...[
              SliverToBoxAdapter(child: AccountSectionLabel(l10n.assets)),
              AccountSliver(
                key: const ValueKey('assets'),
                lines: overview.assets,
                onReorder: (ids) => context.read<AccountsBloc>().add(
                  AccountsReorderPressed(ids),
                ),
              ),
            ],
            if (overview.liabilities.isNotEmpty) ...[
              SliverToBoxAdapter(child: AccountSectionLabel(l10n.liabilities)),
              AccountSliver(
                key: const ValueKey('liabilities'),
                lines: overview.liabilities,
                onReorder: (ids) => context.read<AccountsBloc>().add(
                  AccountsReorderPressed(ids),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
