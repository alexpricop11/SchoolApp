import 'package:get/get.dart';
import '../../../domain/entities/admin_user_entity.dart';
import '../../../domain/usecases/admin_user/get_users_usecase.dart';
import '../../../domain/usecases/admin_user/delete_user_usecase.dart';
import 'package:get_it/get_it.dart';

class AdminUsersController extends GetxController {
  final GetUsersUseCase getUsersUseCase = GetIt.instance.get<GetUsersUseCase>();
  final DeleteUserUseCase deleteUserUseCase = GetIt.instance.get<DeleteUserUseCase>();

  var users = <AdminUserEntity>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await getUsersUseCase();
      users.value = result;
    } catch (e) {
      errorMessage.value = 'Eroare la încărcarea utilizatorilor: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final success = await deleteUserUseCase(userId);
      if (success) {
        users.removeWhere((user) => user.id == userId);
        Get.snackbar('Succes', 'Utilizatorul a fost șters');
      } else {
        Get.snackbar('Eroare', 'Nu s-a putut șterge utilizatorul');
      }
    } catch (e) {
      Get.snackbar('Eroare', 'Eroare la ștergerea utilizatorului: $e');
    }
  }
}