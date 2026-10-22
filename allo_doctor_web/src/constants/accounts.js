// Comptes de référence et démo strictement cloisonnés
export const REGISTERED_ACCOUNTS = {
  patient: {
    uid: 'patient_karim_01',
    email: 'patient@allodoctor.ma',
    display_name: 'Karim Tazi',
    phoneNumber: '+212 661 23 45 67',
    userCategory: 'patient',
    photo_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    blood_group: 'O+',
    city: 'Casablanca'
  },
  doctor: {
    uid: 'doctor_mansouri_01',
    email: 'medecin@allodoctor.ma',
    display_name: 'Dr. Amina Mansouri',
    phoneNumber: '+212 662 89 10 11',
    userCategory: 'doctor',
    profCategory: 'Cardiologue',
    photo_url: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop&q=80',
    experience_years: 12,
    rating: 4.9,
    consultation_fee: 350,
    address: '14 Bd d\'Anfa, Casablanca'
  },
  pharmacy: {
    uid: 'pharma_alamal_01',
    email: 'pharmacie@allodoctor.ma',
    display_name: 'Pharmacie Al Amal',
    phoneNumber: '+212 522 34 56 78',
    userCategory: 'pharmacy',
    profCategory: 'Pharmacie',
    photo_url: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=150&auto=format&fit=crop&q=80',
    is_on_duty: true,
    address: '88 Avenue Hassan II, Casablanca'
  },
  clinic: {
    uid: 'clinic_atlas_01',
    email: 'clinique@allodoctor.ma',
    display_name: 'Clinique Internationale Atlas',
    phoneNumber: '+212 522 99 88 77',
    userCategory: 'clinic',
    profCategory: 'Clinique',
    photo_url: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=150&auto=format&fit=crop&q=80',
    beds_available: 18,
    emergency_open: true,
    address: 'Boulevard Zerktouni, Casablanca'
  },
  admin: {
    uid: 'admin_super_01',
    email: 'admin@allodoctor.ma',
    display_name: 'Superviseur Général (Admin)',
    phoneNumber: '+212 600 00 00 00',
    userCategory: 'admin',
    profCategory: 'Super Administrateur',
    photo_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80'
  }
};
