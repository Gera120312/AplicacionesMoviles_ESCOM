package ovh.gabrielhuav.flasklogin

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class UiState<out T> {
    object Idle : UiState<Nothing>()
    object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}

class AppViewModel : ViewModel() {
    private val api = RetrofitClient.instance

    private val _token = MutableStateFlow<String?>(null)
    val token: StateFlow<String?> = _token.asStateFlow()

    private val _authState = MutableStateFlow<UiState<String>>(UiState.Idle)
    val authState: StateFlow<UiState<String>> = _authState.asStateFlow()

    private val _productsState = MutableStateFlow<UiState<List<Product>>>(UiState.Idle)
    val productsState: StateFlow<UiState<List<Product>>> = _productsState.asStateFlow()

    private val _actionState = MutableStateFlow<UiState<String>>(UiState.Idle)
    val actionState: StateFlow<UiState<String>> = _actionState.asStateFlow()

    fun resetAuthState() {
        _authState.value = UiState.Idle
    }

    fun resetActionState() {
        _actionState.value = UiState.Idle
    }

    fun login(authRequest: AuthRequest) {
        viewModelScope.launch {
            _authState.value = UiState.Loading
            try {
                val response = api.login(authRequest)
                if (response.isSuccessful && response.body() != null) {
                    val token = response.body()?.token
                    _token.value = token
                    _authState.value = UiState.Success("Login successful")
                } else {
                    val errorMsg = response.errorBody()?.string() ?: "Invalid credentials"
                    _authState.value = UiState.Error(errorMsg)
                }
            } catch (e: Exception) {
                _authState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }

    fun register(authRequest: AuthRequest) {
        viewModelScope.launch {
            _authState.value = UiState.Loading
            try {
                val response = api.register(authRequest)
                if (response.isSuccessful) {
                    _authState.value = UiState.Success("Registration successful")
                } else {
                    val errorMsg = response.errorBody()?.string() ?: "Registration failed"
                    _authState.value = UiState.Error(errorMsg)
                }
            } catch (e: Exception) {
                _authState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }

    fun logout() {
        _token.value = null
        _productsState.value = UiState.Idle
        _authState.value = UiState.Idle
    }

    fun getProducts() {
        val currentToken = _token.value ?: return
        viewModelScope.launch {
            _productsState.value = UiState.Loading
            try {
                val response = api.getProducts("Bearer $currentToken")
                if (response.isSuccessful && response.body() != null) {
                    // Extraemos la lista de productos del objeto devuelto
                    _productsState.value = UiState.Success(response.body()!!.products)
                } else {
                    _productsState.value = UiState.Error("Failed to fetch products")
                }
            } catch (e: Exception) {
                _productsState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }

    fun addProduct(productRequest: ProductRequest) {
        val currentToken = _token.value ?: return
        viewModelScope.launch {
            _actionState.value = UiState.Loading
            try {
                val response = api.addProduct("Bearer $currentToken", productRequest)
                if (response.isSuccessful) {
                    _actionState.value = UiState.Success("Product added")
                    getProducts() // Refresh list
                } else {
                    _actionState.value = UiState.Error("Failed to add product")
                }
            } catch (e: Exception) {
                _actionState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }

    fun updateProduct(id: Int, productRequest: ProductRequest) {
        val currentToken = _token.value ?: return
        viewModelScope.launch {
            _actionState.value = UiState.Loading
            try {
                val response = api.updateProduct("Bearer $currentToken", id, productRequest)
                if (response.isSuccessful) {
                    _actionState.value = UiState.Success("Product updated")
                    getProducts() // Refresh list
                } else {
                    _actionState.value = UiState.Error("Failed to update product")
                }
            } catch (e: Exception) {
                _actionState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }

    fun deleteProduct(id: Int) {
        val currentToken = _token.value ?: return
        viewModelScope.launch {
            _actionState.value = UiState.Loading
            try {
                val response = api.deleteProduct("Bearer $currentToken", id)
                if (response.isSuccessful) {
                    _actionState.value = UiState.Success("Product deleted")
                    getProducts() // Refresh list
                } else {
                    _actionState.value = UiState.Error("Failed to delete product")
                }
            } catch (e: Exception) {
                _actionState.value = UiState.Error(e.localizedMessage ?: "Unknown error")
            }
        }
    }
}
