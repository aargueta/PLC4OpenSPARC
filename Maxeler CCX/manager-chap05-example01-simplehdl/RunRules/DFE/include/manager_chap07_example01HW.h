/**\file */
#ifndef SLIC_DECLARATIONS_manager_chap07_example01HW_H
#define SLIC_DECLARATIONS_manager_chap07_example01HW_H
#include "MaxSLiCInterface.h"
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * \brief Simple static function for the interface 'default'
 * 
 * \param [in] instream_max stream max
 * \param [in] instream_size_max size of the stream instream_max in bytes
 * \param [out] outstream_count stream count
 * \param [in] outstream_size_count size of the stream outstream_count in bytes
 */
void manager_chap07_example01HW(
	const void *instream_max,
	size_t instream_size_max,
	void *outstream_count,
	size_t outstream_size_count);

/**
 * \brief Advanced static interface, structure for the engine interface 'default'
 * 
 */
typedef struct { 
	const void *instream_max; /**<  [in] stream max */
	size_t instream_size_max; /**<  [in] size of the stream instream_max in bytes */
	void *outstream_count; /**<  [out] stream count */
	size_t outstream_size_count; /**<  [in] size of the stream outstream_count in bytes */
} manager_chap07_example01HW_actions_t;

/**
 * \brief Advanced static function for the interface 'default'
 * \param [in] engine the engine on which the actions will be executed
 * \param [in,out] interface_actions actions to be executed
 */
void manager_chap07_example01HW_run(
	max_engine_t *engine,
	manager_chap07_example01HW_actions_t *interface_actions);

/**
 * \brief Group run advanced static function for the interface 'default'
 * \param group group to use
 * \param interface_actions actions to run
 *
 * Run the actions on the first device available in the group.
 */
void manager_chap07_example01HW_run_group(max_group_t *group, manager_chap07_example01HW_actions_t *interface_actions);

/**
 * \brief Array run advanced static function for the interface 'default'
 * \param engarray the array of devices to use
 * \param interface_actions the array of actions to run
 *
 * Run the array of actions on the array of engines.  The length of interface_actions
 * must match the size of engarray.
 */
void manager_chap07_example01HW_run_array(max_engarray_t *engarray, manager_chap07_example01HW_actions_t *interface_actions[]);

max_actions_t* manager_chap07_example01HW_convert(max_file_t *maxfile, manager_chap07_example01HW_actions_t *interface_actions);

/**
 * \brief Turn debugging on for the functions in the static 
 *          interface of this maxfile.
 * \param debug_directory directory for the generated files
 */
void manager_chap07_example01HW_debug(const char *debug_directory);

/**
 * \brief Initialise a maxfile.
 */
max_file_t* manager_chap07_example01HW_init(void);
#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif /* SLIC_DECLARATIONS_manager_chap07_example01HW_H */

