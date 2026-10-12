import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Season { normal, halloween, christmas, valentines }

class SeasonTheme {
  final Season season;
  final String displayName;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final IconData likeIcon;
  final IconData likedIcon;
  final IconData commentIcon;
  final IconData bookmarkIcon;
  final IconData badgeIcon;
  final IconData musicIcon;
  final String audioAsset;
  final TextStyle headingStyle;
  final TextStyle bodyStyle;
  final TextStyle captionStyle;
  final LinearGradient gradientOverlay;

  SeasonTheme({
    required this.season,
    required this.displayName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.likeIcon,
    required this.likedIcon,
    required this.commentIcon,
    required this.bookmarkIcon,
    required this.badgeIcon,
    required this.musicIcon,
    required this.audioAsset,
    required this.headingStyle,
    required this.bodyStyle,
    required this.captionStyle,
    required this.gradientOverlay,
  });

  factory SeasonTheme.fromSeason(Season season) {
    switch (season) {
      case Season.halloween:
        return SeasonTheme(
          season: season,
          displayName: 'Halloween & Día de Muertos',
          primaryColor: const Color(0xFFFF6B00), // Naranja cempasúchil / calabaza
          secondaryColor: const Color(0xFF9D4EDD), // Púrpura místico
          accentColor: const Color(0xFF39FF14), // Verde ectoplasma
          backgroundColor: const Color(0xFF0D0B12),
          likeIcon: Icons.local_fire_department_outlined, // Llama mística / cirio
          likedIcon: Icons.local_fire_department_rounded, // Fuego ardiente Día de Muertos
          commentIcon: Icons.maps_ugc_rounded, // Burbuja moderna
          bookmarkIcon: Icons.bookmark_add_rounded,
          badgeIcon: Icons.nightlight_round,
          musicIcon: Icons.graphic_eq_rounded,
          audioAsset: 'assets/audio/halloween.wav',
          headingStyle: GoogleFonts.creepster(
            color: const Color(0xFFFF6B00),
            fontSize: 22,
            letterSpacing: 1.5,
          ),
          bodyStyle: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          captionStyle: GoogleFonts.cinzel(
            color: Colors.white70,
            fontSize: 12,
          ),
          gradientOverlay: const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0x339D4EDD),
              Color(0xDD0D0B12),
            ],
            stops: [0.5, 0.8, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

      case Season.christmas:
        return SeasonTheme(
          season: season,
          displayName: 'Navidad',
          primaryColor: const Color(0xFFE50914), // Rojo navideño
          secondaryColor: const Color(0xFF1E5128), // Verde pino
          accentColor: const Color(0xFFFFD700), // Oro campana
          backgroundColor: const Color(0xFF09140E),
          likeIcon: Icons.star_border_rounded, // Estrella de Belén
          likedIcon: Icons.star_rounded, // Estrella navideña dorada
          commentIcon: Icons.chat_bubble_outline_rounded,
          bookmarkIcon: Icons.card_giftcard_rounded, // Regalo navideño
          badgeIcon: Icons.ac_unit_rounded,
          musicIcon: Icons.music_note_rounded,
          audioAsset: 'assets/audio/christmas.wav',
          headingStyle: GoogleFonts.mountainsOfChristmas(
            color: const Color(0xFFFFD700),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyStyle: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          captionStyle: GoogleFonts.quicksand(
            color: Colors.white70,
            fontSize: 12,
          ),
          gradientOverlay: const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0x331E5128),
              Color(0xDDE50914),
            ],
            stops: [0.5, 0.85, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

      case Season.valentines:
        return SeasonTheme(
          season: season,
          displayName: 'San Valentín',
          primaryColor: const Color(0xFFFF2E93), // Rosa vibrante
          secondaryColor: const Color(0xFFD80032), // Pasión carmín
          accentColor: const Color(0xFFFFB6C1), // Rosa suave
          backgroundColor: const Color(0xFF16080F),
          likeIcon: Icons.favorite_border_rounded,
          likedIcon: Icons.favorite_rounded, // Corazón pasional
          commentIcon: Icons.mark_chat_unread_rounded,
          bookmarkIcon: Icons.bookmark_rounded,
          badgeIcon: Icons.volunteer_activism_rounded,
          musicIcon: Icons.favorite_border_rounded,
          audioAsset: 'assets/audio/valentines.wav',
          headingStyle: GoogleFonts.dancingScript(
            color: const Color(0xFFFF2E93),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          bodyStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          captionStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
          gradientOverlay: const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0x33D80032),
              Color(0xDD16080F),
            ],
            stops: [0.5, 0.8, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

      case Season.normal:
        return SeasonTheme(
          season: season,
          displayName: 'Normal',
          primaryColor: const Color(0xFFFE2C55), // Rojo TikTok
          secondaryColor: const Color(0xFF25F4EE), // Cian TikTok
          accentColor: Colors.white,
          backgroundColor: Colors.black,
          likeIcon: Icons.favorite_border_rounded,
          likedIcon: Icons.favorite_rounded,
          commentIcon: Icons.mode_comment_rounded, // Icono moderno TikTok
          bookmarkIcon: Icons.bookmark_rounded,
          badgeIcon: Icons.auto_awesome_rounded,
          musicIcon: Icons.graphic_eq_rounded,
          audioAsset: 'assets/audio/normal.wav',
          headingStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          bodyStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          captionStyle: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
          ),
          gradientOverlay: const LinearGradient(
            colors: [
              Colors.transparent,
              Color(0x99000000),
              Color(0xF0000000),
            ],
            stops: [0.5, 0.8, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
    }
  }
}
