import { request } from '@umijs/max';
import { RatingCompanyAPI } from './data';

/** 创建评级公司 */
export async function createRatingCompany(params: RatingCompanyAPI.CreateRatingCompanyParams) {
  return request<API.ApiResponse<string>>('/api/products/rating-companies', {
    method: 'POST',
    data: params,
  });
}

/** 创建评级公司（全参数） */
export async function createRatingCompanyWithAllFields(params: RatingCompanyAPI.CreateRatingCompanyWithAllFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/rating-companies/with-all-fields', {
    method: 'POST',
    data: params,
  });
}

/** 查询评级公司详情 */
export async function getRatingCompanyDetail(ratingCompanyId: string) {
  return request<API.ApiResponse<RatingCompanyAPI.RatingCompanyVO>>(`/api/products/rating-companies/${ratingCompanyId}`, {
    method: 'GET',
  });
}

/** 分页查询评级公司 */
export async function getRatingCompanyPage(params: RatingCompanyAPI.RatingCompanyPageParams) {
  return request<API.ApiResponse<API.PageData<RatingCompanyAPI.RatingCompanyVO>>>('/api/products/rating-companies', {
    method: 'GET',
    params,
  });
}

/** 修改名称 */
export async function updateRatingCompanyName(ratingCompanyId: string, params: RatingCompanyAPI.UpdateRatingCompanyNameParams) {
  return request<API.ApiResponse<null>>(`/api/products/rating-companies/${ratingCompanyId}/name`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改官网URL */
export async function updateRatingCompanyOfficialWebsiteUrl(ratingCompanyId: string, params: RatingCompanyAPI.UpdateRatingCompanyOfficialWebsiteUrlParams) {
  return request<API.ApiResponse<null>>(`/api/products/rating-companies/${ratingCompanyId}/official-website-url`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改分值 */
export async function updateRatingCompanyScore(ratingCompanyId: string, params: RatingCompanyAPI.UpdateRatingCompanyScoreParams) {
  return request<API.ApiResponse<null>>(`/api/products/rating-companies/${ratingCompanyId}/score`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改官网信息字段 */
export async function updateRatingCompanyOfficialWebsiteFields(ratingCompanyId: string, params: RatingCompanyAPI.UpdateRatingCompanyOfficialWebsiteFieldsParams) {
  return request<API.ApiResponse<null>>(`/api/products/rating-companies/${ratingCompanyId}/official-website-fields`, {
    method: 'PUT',
    data: params,
  });
}

/** 删除评级公司 */
export async function deleteRatingCompany(ratingCompanyId: string) {
  return request<API.ApiResponse<null>>(`/api/products/rating-companies/${ratingCompanyId}`, {
    method: 'DELETE',
  });
} 