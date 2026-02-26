class ProfileUtils {
  static String toFrench(String? profil) {
    switch (profil) {
      case 'PROMOTEUR':
        return 'Promoteur';
      case 'NOTAIRE':
        return 'Notaire';
      case 'RESERVATAIRE':
        return 'Réservataire';
      case 'BANK':
        return 'Banque';
      case 'AGENCY':
        return 'Agence';
      case 'ADMIN':
        return 'Administrateur';

      case 'PROPRIETAIRE':
        return 'Propriétaire';
      case 'SYNDIC':
        return 'Syndic';
      case 'LOCATAIRE':
        return 'Locataire';
      case 'PRESTATAIRE':
        return 'Prestataire';
      case 'TOM':
        return 'TOM';

      case 'SITE_MANAGER':
        return 'Chef de chantier';
      case 'SUPPLIER':
        return 'Fournisseur';
      case 'SUBCONTRACTOR':
        return 'Sous-traitant';
      case 'WORKER':
        return 'Ouvrier';
      case 'MOA':
        return 'Maître d’ouvrage (MOA)';
      case 'BET':
        return 'Bureau d’études (BET)';

      default:
        return profil ?? 'Profil inconnu';
    }
  }
}
