class AppAssets {
  AppAssets._();

  // ─── Logo & UI images ──────────────────────────────────────────────────────
  static const String logo    = 'assets/images/logo_braxorzone.png';
  static const String skipBtn = 'assets/images/skip_button.png';

  // ─── Backgrounds ───────────────────────────────────────────────────────────
  static const String bgSplash = 'assets/backgrounds/bg_splash.png';
  static const String bgHome   = 'assets/backgrounds/bg_home.png';
  // legacy alias
  static const String hexBackground  = bgHome;
  static const String bgDefault      = bgHome;

  // ─── Scanner overlay (full-size image over camera) ─────────────────────────
  static const String scannerOverlay = 'assets/images/scanner_overlay.png';

  // ─── Navigation icons ──────────────────────────────────────────────────────
  static const String navHome    = 'assets/icons/nav_home.png';
  static const String navOffers  = 'assets/icons/nav_offers.png';
  static const String navBooking = 'assets/icons/nav_booking.png';
  static const String navQr      = 'assets/icons/nav_qr.png';
  static const String navProfile = 'assets/icons/nav_profile.png';

  // ─── UI icons ──────────────────────────────────────────────────────────────
  static const String icNotification = 'assets/icons/ic_notification.png';
  static const String icFlash        = 'assets/icons/ic_flash.png';
  static const String icQrScan       = 'assets/icons/ic_qr_scan.png';
  static const String icArrowRight   = 'assets/icons/ic_arrow_right.png';
  static const String icClose        = 'assets/icons/ic_close.png';
  static const String icAdd          = 'assets/icons/ic_add.png';
  static const String icCheck        = 'assets/icons/ic_check.png';
  static const String icCheckCircle  = 'assets/icons/ic_check_circle.png';
  static const String icInfo         = 'assets/icons/ic_info.png';
  static const String icTimer        = 'assets/icons/ic_timer.png';
  static const String icFlag         = 'assets/icons/ic_flag.png';
  static const String icPersonAdd    = 'assets/icons/ic_person_add.png';
  static const String icBack         = 'assets/icons/ic_back.png';
  static const String icCalendar     = 'assets/icons/ic_calendar.png';
  static const String icClock        = 'assets/icons/ic_clock.png';
  static const String icShield       = 'assets/icons/ic_shield.png';
  static const String icLock         = 'assets/icons/ic_lock.png';
  static const String icLocation     = 'assets/icons/ic_location.png';
  static const String icPhone        = 'assets/icons/ic_phone.png';
  static const String icPerson       = 'assets/icons/ic_person.png';
  static const String icSports       = 'assets/icons/ic_sports.png';
  static const String icStar         = 'assets/icons/ic_star.png';
  static const String icTrophy       = 'assets/icons/ic_trophy.png';
  static const String icChevronRight = 'assets/icons/ic_chevron_right.png';
  static const String icPlus         = 'assets/icons/ic_plus.png';
  static const String icMinus        = 'assets/icons/ic_minus.png';
  static const String icBookTable    = 'assets/icons/ic_book_table.png';
  static const String icPromos       = 'assets/icons/ic_promos.png';
  static const String icLoyalty      = 'assets/icons/ic_loyalty.png';
  static const String icPremium      = 'assets/icons/ic_premium.png';
  static const String icOfferTag     = 'assets/icons/ic_offer_tag.png';
  static const String icTable        = 'assets/icons/ic_table.png';

  // ─── Onboarding illustrations ──────────────────────────────────────────────
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String onboarding4 = 'assets/images/onboarding_4.png';

  // ─── Success & success state illustrations ─────────────────────────────────
  static const String successBilliard = 'assets/images/success_billiard.png';
  static const String successQr       = 'assets/images/qr_success.png';

  // ─── Profile & loyalty ─────────────────────────────────────────────────────
  static const String avatarDefault = 'assets/images/avatar_default.png';

  // ─── Player avatars (place files in assets/avatars/) ──────────────────────
  static const List<String> playerAvatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/avatar_5.png',
    'assets/avatars/avatar_6.png',
  ];
  static const String unlockNextBg  = 'assets/images/unlock_next_bg.png';
  static const String premiumCue    = 'assets/images/premium_cue.png';

  // ─── Tier badges ───────────────────────────────────────────────────────────
  static const String tierRookie  = 'assets/tiers/tier_rookie.png';
  static const String tierPlayer  = 'assets/tiers/tier_player.png';
  static const String tierPro     = 'assets/tiers/tier_pro.png';
  static const String tierMaster  = 'assets/tiers/tier_master.png';
  static const String tierLegend  = 'assets/tiers/tier_legend.png';

  // ─── Mission icons ─────────────────────────────────────────────────────────
  static const String missionFirstVisit  = 'assets/missions/mission_first_visit.png';
  static const String missionRegular     = 'assets/missions/mission_regular.png';
  static const String missionTournament  = 'assets/missions/mission_tournament.png';
  static const String missionDedicated   = 'assets/missions/mission_dedicated.png';
  static const String missionOnRoll      = 'assets/missions/mission_on_roll.png';
  static const String missionMonthly     = 'assets/missions/mission_monthly.png';
  static const String missionEarlyBird   = 'assets/missions/mission_early_bird.png';
  static const String missionNightOwl    = 'assets/missions/mission_night_owl.png';
  static const String missionVeteran     = 'assets/missions/mission_veteran.png';
  static const String missionUnstoppable = 'assets/missions/mission_unstoppable.png';
  static const String missionLegend      = 'assets/missions/mission_legend.png';

  // ─── Price package icons ───────────────────────────────────────────────────
  static const String priceCleanShot  = 'assets/prices/price_clean_shot.png';
  static const String priceGameShift  = 'assets/prices/price_game_shift.png';
  static const String priceNonStop    = 'assets/prices/price_non_stop.png';
  static const String priceNightSeries = 'assets/prices/price_night_series.png';

  // ─── Club branch icons ─────────────────────────────────────────────────────
  static const String clubCentral   = 'assets/clubs/club_central.png';
  static const String clubNightHall = 'assets/clubs/club_night_hall.png';
  static const String clubArena     = 'assets/clubs/club_arena.png';

  // ─── Tournament banners (referenced by tournament id) ──────────────────────
  static String tournamentBanner(String id) => 'assets/banners/banner_tournament_$id.png';

  // ─── Promo banners ─────────────────────────────────────────────────────────
  static const String promoDoubleBreak  = 'assets/images/promo_double_break.png';
  static const String promoIronFriday   = 'assets/images/promo_iron_friday.png';
  static const String promoNightLights  = 'assets/images/promo_night_lights.png';
  static const String promoTableForTwo  = 'assets/images/promo_table_for_two.png';

  // ─── Club rules icons ──────────────────────────────────────────────────────
  static const String ruleEtiquette = 'assets/icons/rule_etiquette.png';
  static const String ruleEquipment = 'assets/icons/rule_equipment.png';
  static const String rulePunctual  = 'assets/icons/rule_punctual.png';
  static const String ruleDressCode = 'assets/icons/rule_dress_code.png';
  static const String ruleFairPlay  = 'assets/icons/rule_fair_play.png';
  static const String rulePrivacy   = 'assets/icons/rule_privacy.png';
}
