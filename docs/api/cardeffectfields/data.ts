

import { DynamicFieldTemplate } from '@/components/DynamicField/types';

export namespace CardEffectFieldsAPI {

  /** 卡牌效果模板详情视图 */
  export interface CardEffectFieldsVO {
    /** 主键 */
    id: string;
    /** 效果字段模板 */
    effectFields: DynamicFieldTemplate[];
    /** 模板名 */
    templateName: string;
    /** 审计信息 */
    auditMetadata: API.AuditMetadata;
  }

  /** 创建卡牌效果模板参数 */
  export interface CreateCardEffectFieldsParams {
    /** 模板名 */
    templateName: string;
  }

  /** 创建卡牌效果模板（全参数）参数 */
  export interface CreateCardEffectFieldsWithAllFieldsParams {
    /** 效果字段模板 */
    effectFields?: DynamicFieldTemplate[];
    /** 模板名 */
    templateName: string;
  }

  /** 修改模板名参数 */
  export interface UpdateCardEffectFieldsTemplateNameParams {
    /** 模板名 */
    templateName: string;
  }

  /** 修改效果字段模板参数 */
  export interface UpdateCardEffectFieldsEffectFieldsParams {
    /** 效果字段模板 */
    effectFields: DynamicFieldTemplate[];
  }

  /** 分页查询卡牌效果模板参数 */
  export interface CardEffectFieldsPageParams extends API.PageParams {
    /** 字段名（模糊查询） */
    fieldName?: string;
    /** 字段类型 */
    fieldType?: string;
    /** 显示名称（模糊查询） */
    displayName?: string;
    /** 是否必填 */
    required?: boolean;
    /** 字段描述（模糊查询） */
    description?: string;
    /** 模板名 */
    templateName?: string;
    
    /** 创建时间范围开始 */
    createdAtStart?: string;
    /** 创建时间范围结束 */
    createdAtEnd?: string;
    /** 更新时间范围开始 */
    updatedAtStart?: string;
    /** 更新时间范围结束 */
    updatedAtEnd?: string;
    /** 创建者（模糊查询） */
    createdBy?: string;
    /** 更新者（模糊查询） */
    updatedBy?: string;
  }

} 