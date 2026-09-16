package ovh.gabrielhuav.flasklogin

import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*

data class AuthRequest(val username: String, val password: String)
data class AuthResponse(val token: String, val username: String)
data class MessageResponse(val message: String)

data class Product(
    val id: Int,
    val name: String,
    val quantity: Int,
    val price: Float
)

data class ProductRequest(
    val name: String,
    val quantity: Int,
    val price: Float
)

data class ProductResponse(
    val products: List<Product>
)

interface ApiService {
    @POST("/register")
    suspend fun register(@Body request: AuthRequest): Response<MessageResponse>

    @POST("/login")
    suspend fun login(@Body request: AuthRequest): Response<AuthResponse>

    @GET("/products")
    suspend fun getProducts(@Header("Authorization") token: String): Response<ProductResponse>

    @POST("/products")
    suspend fun addProduct(
        @Header("Authorization") token: String,
        @Body product: ProductRequest
    ): Response<Product>

    @PUT("/products/{id}")
    suspend fun updateProduct(
        @Header("Authorization") token: String,
        @Path("id") id: Int,
        @Body product: ProductRequest
    ): Response<Product>

    @DELETE("/products/{id}")
    suspend fun deleteProduct(
        @Header("Authorization") token: String,
        @Path("id") id: Int
    ): Response<MessageResponse>
}

object RetrofitClient {
    private const val BASE_URL = "http://10.0.2.2:5000"

    val instance: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}
